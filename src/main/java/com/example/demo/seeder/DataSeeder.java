package com.example.demo.seeder;

import com.example.demo.model.Division;
import com.example.demo.model.DivisionType;
import com.example.demo.model.Locality;
import com.example.demo.model.User;
import com.example.demo.model.Complaint;
import com.example.demo.model.Photo;
import com.example.demo.model.Village;
import com.example.demo.repository.DivisionRepository;
import com.example.demo.repository.LocalityRepository;
import com.example.demo.repository.UserRepository;
import com.example.demo.repository.ComplaintRepository;
import com.example.demo.repository.PhotoRepository;
import com.example.demo.repository.VillageRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Component
public class DataSeeder implements CommandLineRunner {

    private final DivisionRepository divisionRepository;
    private final LocalityRepository localityRepository;
    private final UserRepository userRepository;
    private final ComplaintRepository complaintRepository;
    private final PhotoRepository photoRepository;
    private final VillageRepository villageRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${app.seed.demo-data:true}")
    private boolean demoDataEnabled;

    @Value("${app.seed.photo-directory:/home/naga/Downloads/complaint_photos}")
    private String photoDirectory;

    public DataSeeder(DivisionRepository divisionRepository,
                      LocalityRepository localityRepository,
                      UserRepository userRepository,
                      ComplaintRepository complaintRepository,
                      PhotoRepository photoRepository,
                      VillageRepository villageRepository,
                      PasswordEncoder passwordEncoder) {
        this.divisionRepository = divisionRepository;
        this.localityRepository = localityRepository;
        this.userRepository = userRepository;
        this.complaintRepository = complaintRepository;
        this.photoRepository = photoRepository;
        this.villageRepository = villageRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) throws Exception {
        ensureDivisionsExist();
        ensureLocalitiesExist();
        ensureAdminUserExist();

        if (demoDataEnabled) {
            ensureDemoUsersExist();
            ensureDemoComplaintsExist();
            ensureDemoPhotosExist();
        }
    }

    private void ensureDivisionsExist() {
        if (divisionRepository.count() == 0) {
            Path divisionsPath = Paths.get("src/main/resources/data/divisions.json");
            if (Files.exists(divisionsPath)) {
                try {
                    String content = Files.readString(divisionsPath);
                    content = content.trim();
                    if (content.startsWith("[")) {
                        com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
                        List<java.util.Map<String, Object>> divisions = mapper.readValue(content, List.class);
                        for (java.util.Map<String, Object> divMap : divisions) {
                            Division division = new Division();
                            division.setName((String) divMap.get("name"));
                            division.setCode((String) divMap.get("code"));
                            division.setType(DivisionType.valueOf((String) divMap.get("type")));
                            division.setCreatedAt(java.time.LocalDateTime.now());
                            divisionRepository.save(division);
                        }
                    }
                } catch (Exception e) {
                    System.out.println("WARNING: Failed to load divisions.json: " + e.getMessage());
                }
            }
        }
    }

    private void ensureLocalitiesExist() {
        if (localityRepository.count() == 0) {
            Path localitiesPath = Paths.get("src/main/resources/data/localities.json");
            if (Files.exists(localitiesPath)) {
                try {
                    String content = Files.readString(localitiesPath);
                    content = content.trim();
                    if (content.startsWith("[")) {
                        com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
                        List<java.util.Map<String, Object>> localities = mapper.readValue(content, List.class);
                        for (java.util.Map<String, Object> locMap : localities) {
                            String divisionCode = (String) locMap.get("divisionCode");
                            Optional<Division> divisionOpt = divisionRepository.findAll().stream()
                                    .filter(d -> d.getCode() != null && d.getCode().equals(divisionCode))
                                    .findFirst();
                            if (divisionOpt.isPresent()) {
                                Locality locality = new Locality();
                                locality.setName((String) locMap.get("name"));
                                locality.setCode((String) locMap.get("code"));
                                locality.setDivision(divisionOpt.get());
                                locality.setCreatedAt(java.time.LocalDateTime.now());
                                localityRepository.save(locality);
                            }
                        }
                    }
                } catch (Exception e) {
                    System.out.println("WARNING: Failed to load localities.json: " + e.getMessage());
                }
            }
        }
    }

    private void ensureAdminUserExist() {
        if (userRepository.findByUsername("admin").isEmpty()) {
            User admin = new User();
            admin.setUsername("admin");
            admin.setEmail("admin@example.com");
            admin.setPassword(passwordEncoder.encode("admin123"));
            admin.setRole("ADMIN");
            admin.setVillage(null);
            userRepository.save(admin);
        }
    }

    private void ensureDemoUsersExist() {
        if (!userRepository.existsByIsDemo(true)) {
            List<Locality> localities = localityRepository.findAll();
            if (localities.isEmpty()) {
                return;
            }

            List<User> demoUsers = new ArrayList<>();
            for (Locality locality : localities) {
                String username = locality.getCode() != null ? locality.getCode() : locality.getName().toLowerCase().replace(" ", "_");
                User user = new User();
                user.setUsername(username);
                user.setEmail(username + "@example.com");
                user.setPassword(passwordEncoder.encode("password123"));
                user.setRole("LOCALITY_USER");
                Village village = villageRepository.findByName(locality.getName())
                        .orElseGet(() -> villageRepository.save(new Village(locality.getName(), null)));
                user.setVillage(village);
                user.setDemo(true);
                demoUsers.add(user);
            }

            userRepository.saveAll(demoUsers);
        }
    }

    private void ensureDemoComplaintsExist() {
        if (!complaintRepository.existsByIsDemo(true)) {
            List<User> demoUsers = userRepository.findByRole("LOCALITY_USER");
            if (demoUsers.isEmpty()) {
                return;
            }

            Path templatesPath = Paths.get("src/main/resources/data/complaint-templates.json");
            List<java.util.Map<String, Object>> templates = new ArrayList<>();
            if (Files.exists(templatesPath)) {
                try {
                    String content = Files.readString(templatesPath);
                    content = content.trim();
                    if (content.startsWith("[")) {
                        com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
                        templates = mapper.readValue(content, List.class);
                    }
                } catch (Exception e) {
                    System.out.println("WARNING: Failed to load complaint-templates.json: " + e.getMessage());
                }
            }

            List<Complaint> demoComplaints = new ArrayList<>();
            for (User user : demoUsers) {
                Complaint complaint = new Complaint();
                complaint.setUser(user);
                complaint.setDemo(true);

                if (!templates.isEmpty()) {
                    int templateIndex = Math.abs(user.getUsername().hashCode()) % templates.size();
                    java.util.Map<String, Object> template = templates.get(templateIndex);
                    complaint.setType((String) template.get("type"));
                    complaint.setOtherType((String) template.get("otherType"));
                    complaint.setContent((String) template.get("description"));
                } else {
                    complaint.setType("OTHER");
                    complaint.setOtherType("General complaint");
                    complaint.setContent("This is a demo complaint for testing purposes.");
                }

                demoComplaints.add(complaint);
            }

            complaintRepository.saveAll(demoComplaints);
        }
    }

    private void ensureDemoPhotosExist() {
        List<Complaint> demoComplaints = complaintRepository.findByIsDemoTrue();
        if (demoComplaints.isEmpty()) {
            return;
        }

        boolean hasPhotos = photoRepository.count() > 0;
        if (hasPhotos) {
            return;
        }

        Path dir = Paths.get(photoDirectory);
        if (!Files.exists(dir) || !Files.isDirectory(dir)) {
            System.out.println("WARNING: Photo directory not found: " + photoDirectory + ". Skipping photo seeding.");
            return;
        }

        File[] files = dir.toFile().listFiles();
        if (files == null || files.length == 0) {
            System.out.println("WARNING: Photo directory is empty: " + photoDirectory + ". Skipping photo seeding.");
            return;
        }

        int photoIndex = 0;
        for (Complaint complaint : demoComplaints) {
            if (photoIndex >= files.length) {
                break;
            }

            try {
                byte[] data = Files.readAllBytes(files[photoIndex].toPath());
                Photo photo = new Photo();
                photo.setData(data);
                photo.setContentType("image/jpeg");
                photo.setComplaint(complaint);
                photo.setDemo(true);
                photoRepository.save(photo);
                photoIndex++;
            } catch (IOException e) {
                System.out.println("WARNING: Failed to read photo: " + files[photoIndex].getName());
            }
        }
    }
}

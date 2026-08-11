package com.example.demo.controller;

import com.example.demo.model.Complaint;
import com.example.demo.model.Photo;
import com.example.demo.model.User;
import com.example.demo.model.Village;
import com.example.demo.repository.ComplaintRepository;
import com.example.demo.repository.PhotoRepository;
import com.example.demo.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Controller
@PreAuthorize("hasAnyRole('ADMIN', 'LOCALITY_USER')")
public class ComplaintController {

    @Autowired
    private ComplaintRepository complaintRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PhotoRepository photoRepository;

    @PreAuthorize("hasRole('LOCALITY_USER')")
    @GetMapping("/complaint")
    public String showComplaintForm(Model model, @AuthenticationPrincipal UserDetails userDetails) {
        User currentUser = userRepository.findByUsername(userDetails.getUsername())
                .orElseThrow(() -> new IllegalStateException("Authenticated user not found"));
        String localityName = currentUser.getVillage() != null ? currentUser.getVillage().getName() : currentUser.getUsername();
        model.addAttribute("localityName", localityName);
        return "complaint-form";
    }

    @PreAuthorize("hasRole('LOCALITY_USER')")
    @PostMapping("/complaint")
    public String submitComplaint(@RequestParam String complaintContent,
                                  @RequestParam("photos") MultipartFile[] photos,
                                  @RequestParam(value = "createdAt", required = false) String createdAtStr,
                                  @RequestParam(value = "type", required = false) String type,
                                  @RequestParam(value = "otherType", required = false) String otherType,
                                  @RequestParam(value = "priority", required = false) String priority,
                                  @AuthenticationPrincipal UserDetails userDetails,
                                  Model model) throws IOException {

        User currentUser = userRepository.findByUsername(userDetails.getUsername())
                .orElseThrow(() -> new IllegalStateException("Authenticated user not found"));

        Complaint complaint = new Complaint();
        complaint.setUser(currentUser);
        complaint.setContent(complaintContent);
        complaint.setType(type);
        complaint.setOtherType(otherType);

        if (createdAtStr != null && !createdAtStr.isBlank()) {
            try {
                LocalDateTime parsed = LocalDateTime.parse(createdAtStr, DateTimeFormatter.ISO_DATE_TIME);
                complaint.setCreatedAt(parsed);
            } catch (Exception e) {
                // ignore invalid format and use default
            }
        }

        List<Photo> savedPhotos = new ArrayList<>();
        for (MultipartFile photo : photos) {
            if (!photo.isEmpty()) {
                Photo photoEntity = new Photo(
                        photo.getBytes(),
                        photo.getContentType(),
                        complaint
                );
                savedPhotos.add(photoEntity);
            }
        }
        complaint.setPhotos(savedPhotos);
        complaintRepository.save(complaint);

        model.addAttribute("success", true);
        return "complaint-form";
    }

    @GetMapping("/complaints/my")
    @PreAuthorize("hasRole('LOCALITY_USER')")
    public String myComplaints(@AuthenticationPrincipal UserDetails userDetails,
                               @RequestParam(value = "type", required = false) String type,
                               Model model) {
        User currentUser = userRepository.findByUsername(userDetails.getUsername())
                .orElseThrow(() -> new IllegalStateException("Authenticated user not found"));

        Village village = currentUser.getVillage();
        if (village == null) {
            model.addAttribute("complaints", List.of());
            model.addAttribute("villageName", currentUser.getUsername());
            model.addAttribute("selectedType", type);
            return "my-complaints";
        }

        List<Complaint> complaints = complaintRepository.findByUser_Village_Id(village.getId());

        if (type != null && !type.isBlank()) {
            complaints = complaints.stream()
                    .filter(c -> type.equals(c.getType()))
                    .collect(Collectors.toList());
        }

        model.addAttribute("complaints", complaints);
        model.addAttribute("villageName", village.getName());
        model.addAttribute("selectedType", type);
        return "my-complaints";
    }

    @GetMapping("/complaints/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'LOCALITY_USER')")
    public String complaintDetail(@PathVariable Long id,
                                  @AuthenticationPrincipal UserDetails userDetails,
                                  Model model) {
        Complaint complaint = complaintRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Complaint not found: " + id));

        User currentUser = userRepository.findByUsername(userDetails.getUsername())
                .orElseThrow(() -> new IllegalStateException("Authenticated user not found"));

        boolean isAdmin = currentUser.getRole().equalsIgnoreCase("ADMIN");
        if (!isAdmin) {
            Village complaintVillage = complaint.getUser() != null ? complaint.getUser().getVillage() : null;
            Village currentVillage = currentUser.getVillage();
            if (complaintVillage == null || currentVillage == null ||
                    !complaintVillage.getId().equals(currentVillage.getId())) {
                throw new AccessDeniedException("Access denied");
            }
        }

        model.addAttribute("complaint", complaint);
        return "complaint-detail";
    }

    @GetMapping("/photos/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'LOCALITY_USER')")
    public ResponseEntity<byte[]> servePhoto(@PathVariable Long id) {
        Photo photo = photoRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Photo not found: " + id));

        if (photo.getData() == null || photo.getData().length == 0) {
            return ResponseEntity.notFound().build();
        }

        MediaType mediaType = MediaType.IMAGE_JPEG;
        if (photo.getContentType() != null) {
            try {
                mediaType = MediaType.parseMediaType(photo.getContentType());
            } catch (Exception e) {
                mediaType = MediaType.IMAGE_JPEG;
            }
        }

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(mediaType);
        headers.setContentLength(photo.getData().length);

        return new ResponseEntity<>(photo.getData(), headers, HttpStatus.OK);
    }
}

package com.example.demo.controller;

import com.example.demo.model.Complaint;
import com.example.demo.model.Division;
import com.example.demo.model.Locality;
import com.example.demo.model.Mandal;
import com.example.demo.model.Village;
import com.example.demo.repository.ComplaintRepository;
import com.example.demo.repository.DivisionRepository;
import com.example.demo.repository.LocalityRepository;
import com.example.demo.repository.MandalRepository;
import com.example.demo.repository.UserRepository;
import com.example.demo.repository.VillageRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.io.ByteArrayOutputStream;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/admin")
public class AdminDashboardController {

    public static class MandalReportItem {
        private String villageName;
        private String mandalName;
        private String submittedDate;
        private String submittedTime;

        public MandalReportItem(String villageName, String mandalName, String submittedDate, String submittedTime) {
            this.villageName = villageName;
            this.mandalName = mandalName;
            this.submittedDate = submittedDate;
            this.submittedTime = submittedTime;
        }

        public String getVillageName() {
            return villageName;
        }

        public String getMandalName() {
            return mandalName;
        }

        public String getSubmittedDate() {
            return submittedDate;
        }

        public String getSubmittedTime() {
            return submittedTime;
        }
    }

    @Autowired
    private MandalRepository mandalRepository;

    @Autowired
    private DivisionRepository divisionRepository;

    @Autowired
    private VillageRepository villageRepository;

    @Autowired
    private ComplaintRepository complaintRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private LocalityRepository localityRepository;

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/dashboard")
    public String adminDashboard(Model model) {
        return "admin-dashboard";
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/localities")
    public String adminLocalities(
            @RequestParam(value = "type", required = false) String type,
            Model model) {

        List<Division> divisions = divisionRepository.findAll();
        List<Village> allVillages = villageRepository.findAll();
        List<Complaint> allComplaints = complaintRepository.findAll();

        Map<Long, List<Complaint>> complaintsByVillageId = allComplaints.stream()
                .filter(c -> c.getUser() != null && c.getUser().getVillage() != null)
                .collect(Collectors.groupingBy(c -> c.getUser().getVillage().getId()));

        Map<Long, String> localityStatusMap = new java.util.HashMap<>();
        Map<Long, java.time.LocalDateTime> localityLastSubmissionMap = new java.util.HashMap<>();

        for (Division d : divisions) {
            for (Locality l : d.getLocalities()) {
                Village matchedVillage = allVillages.stream()
                        .filter(v -> l.getName().equalsIgnoreCase(v.getName()))
                        .findFirst()
                        .orElse(null);
                if (matchedVillage == null) {
                    localityStatusMap.put(l.getId(), "No Reports");
                } else {
                    List<Complaint> vComplaints = complaintsByVillageId.getOrDefault(matchedVillage.getId(), List.of());
                    if (vComplaints.isEmpty()) {
                        localityStatusMap.put(l.getId(), "No Reports");
                    } else {
                        List<Complaint> sorted = vComplaints.stream()
                                .sorted((a, b) -> b.getCreatedAt().compareTo(a.getCreatedAt()))
                                .toList();
                        localityLastSubmissionMap.put(l.getId(), sorted.get(0).getCreatedAt());
                        long daysSince = java.time.temporal.ChronoUnit.DAYS.between(
                                sorted.get(0).getCreatedAt().toLocalDate(),
                                java.time.LocalDate.now()
                        );
                        localityStatusMap.put(l.getId(), daysSince > 14 ? "Pending" : "Active");
                    }
                }
            }
        }

        java.util.Map<com.example.demo.model.DivisionType, List<Division>> grouped = divisions.stream()
                .collect(java.util.stream.Collectors.groupingBy(Division::getType));

        if (type != null && !type.isBlank()) {
            try {
                com.example.demo.model.DivisionType selectedType = com.example.demo.model.DivisionType.valueOf(type);
                grouped = grouped.entrySet().stream()
                        .filter(e -> e.getKey() == selectedType)
                        .collect(java.util.stream.Collectors.toMap(java.util.Map.Entry::getKey, java.util.Map.Entry::getValue));
            } catch (IllegalArgumentException e) {
                // ignore invalid type
            }
        }

        java.util.Map<Long, Long> divisionStats = new java.util.HashMap<>();
        for (Division d : divisions) {
            long count = 0;
            for (Locality l : d.getLocalities()) {
                Village matchedVillage = allVillages.stream()
                        .filter(v -> l.getName().equalsIgnoreCase(v.getName()))
                        .findFirst()
                        .orElse(null);
                if (matchedVillage != null) {
                    count += complaintsByVillageId.getOrDefault(matchedVillage.getId(), List.of()).size();
                }
            }
            divisionStats.put(d.getId(), count);
        }

        long mandalCount = grouped.getOrDefault(com.example.demo.model.DivisionType.MANDAL, List.of()).size();
        long municipalityCount = grouped.getOrDefault(com.example.demo.model.DivisionType.MUNICIPALITY, List.of()).size();
        long corporationCount = grouped.getOrDefault(com.example.demo.model.DivisionType.CORPORATION, List.of()).size();
        long nagarPanchayatCount = grouped.getOrDefault(com.example.demo.model.DivisionType.NAGAR_PANCHAYAT, List.of()).size();

        List<Division> filteredDivisions = List.of();
        if (type != null && !type.isBlank()) {
            try {
                com.example.demo.model.DivisionType selectedType = com.example.demo.model.DivisionType.valueOf(type);
                filteredDivisions = divisions.stream()
                        .filter(d -> d.getType() == selectedType)
                        .toList();
            } catch (IllegalArgumentException e) {
                // ignore invalid type
            }
        }

        model.addAttribute("groupedDivisions", grouped);
        model.addAttribute("divisionTypes", com.example.demo.model.DivisionType.values());
        model.addAttribute("selectedType", type);
        model.addAttribute("mandalCount", mandalCount);
        model.addAttribute("municipalityCount", municipalityCount);
        model.addAttribute("corporationCount", corporationCount);
        model.addAttribute("nagarPanchayatCount", nagarPanchayatCount);
        model.addAttribute("divisionStats", divisionStats);
        model.addAttribute("filteredDivisions", filteredDivisions);
        model.addAttribute("localityStatusMap", localityStatusMap);
        model.addAttribute("localityLastSubmissionMap", localityLastSubmissionMap);
        return "admin-localities";
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/division/{id}")
    public String divisionDetails(@PathVariable("id") Long id, Model model) {
        Division division = divisionRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Division not found: " + id));

        List<Locality> localities = division.getLocalities();

        java.util.Map<Long, java.time.LocalDateTime> lastSubmissionMap = new java.util.HashMap<>();
        java.util.Map<Long, String> statusMap = new java.util.HashMap<>();
        java.util.Map<Long, Long> complaintCountMap = new java.util.HashMap<>();
        java.util.Map<Long, String> lastReportMap = new java.util.HashMap<>();

        java.util.List<Locality> sortedLocalities = new java.util.ArrayList<>(localities);
        sortedLocalities.sort((a, b) -> {
            String statusA = getLocalityStatus(a, lastSubmissionMap, statusMap, lastReportMap);
            String statusB = getLocalityStatus(b, lastSubmissionMap, statusMap, lastReportMap);
            int orderA = switch (statusA) {
                case "No Reports" -> 0;
                case "Pending" -> 1;
                case "Active" -> 2;
                default -> 3;
            };
            int orderB = switch (statusB) {
                case "No Reports" -> 0;
                case "Pending" -> 1;
                case "Active" -> 2;
                default -> 3;
            };
            if (orderA != orderB) {
                return Integer.compare(orderA, orderB);
            }
            LocalDateTime dateA = lastSubmissionMap.getOrDefault(a.getId(), LocalDateTime.MIN);
            LocalDateTime dateB = lastSubmissionMap.getOrDefault(b.getId(), LocalDateTime.MIN);
            return dateB.compareTo(dateA);
        });

        for (Locality locality : sortedLocalities) {
            List<Complaint> localityComplaints = List.of();
            Village matchedVillage = villageRepository.findByName(locality.getName()).orElse(null);
            if (matchedVillage != null) {
                localityComplaints = complaintRepository.findByUserVillage(matchedVillage);
            }
            complaintCountMap.put(locality.getId(), (long) localityComplaints.size());
            if (localityComplaints.isEmpty()) {
                statusMap.put(locality.getId(), "No Reports");
                lastReportMap.put(locality.getId(), "Never");
            } else {
                lastSubmissionMap.put(locality.getId(), localityComplaints.get(0).getCreatedAt());
                long daysSince = java.time.temporal.ChronoUnit.DAYS.between(
                        localityComplaints.get(0).getCreatedAt().toLocalDate(),
                        java.time.LocalDate.now()
                );
                if (daysSince == 0) {
                    lastReportMap.put(locality.getId(), "Today");
                } else if (daysSince == 1) {
                    lastReportMap.put(locality.getId(), "Yesterday");
                } else {
                    lastReportMap.put(locality.getId(), daysSince + " days ago");
                }
                if (daysSince > 14) {
                    statusMap.put(locality.getId(), "Pending");
                } else {
                    statusMap.put(locality.getId(), "Active");
                }
            }
        }

        model.addAttribute("division", division);
        model.addAttribute("localities", sortedLocalities);
        model.addAttribute("lastSubmissionMap", lastSubmissionMap);
        model.addAttribute("lastReportMap", lastReportMap);
        model.addAttribute("statusMap", statusMap);
        model.addAttribute("complaintCountMap", complaintCountMap);
        return "admin-division";
    }

    private String getLocalityStatus(Locality locality, java.util.Map<Long, java.time.LocalDateTime> lastSubmissionMap, java.util.Map<Long, String> statusMap, java.util.Map<Long, String> lastReportMap) {
        if (statusMap.containsKey(locality.getId())) {
            return statusMap.get(locality.getId());
        }
        List<Complaint> localityComplaints = List.of();
        Village matchedVillage = villageRepository.findByName(locality.getName()).orElse(null);
        if (matchedVillage != null) {
            localityComplaints = complaintRepository.findByUserVillage(matchedVillage);
        }
        if (localityComplaints.isEmpty()) {
            statusMap.put(locality.getId(), "No Reports");
            if (lastReportMap != null) {
                lastReportMap.put(locality.getId(), "Never");
            }
        } else {
            lastSubmissionMap.put(locality.getId(), localityComplaints.get(0).getCreatedAt());
            long daysSince = java.time.temporal.ChronoUnit.DAYS.between(
                    localityComplaints.get(0).getCreatedAt().toLocalDate(),
                    java.time.LocalDate.now()
            );
            if (lastReportMap != null) {
                if (daysSince == 0) {
                    lastReportMap.put(locality.getId(), "Today");
                } else if (daysSince == 1) {
                    lastReportMap.put(locality.getId(), "Yesterday");
                } else {
                    lastReportMap.put(locality.getId(), daysSince + " days ago");
                }
            }
            statusMap.put(locality.getId(), daysSince > 14 ? "Pending" : "Active");
        }
        return statusMap.get(locality.getId());
    }

    private List<Complaint> getLatestComplaintsForVillage(Village village) {
        List<Complaint> complaints = complaintRepository.findByUser_Village_Id(village.getId());
        return complaints.stream()
                .filter(c -> c.getCreatedAt() != null)
                .sorted((a, b) -> b.getCreatedAt().compareTo(a.getCreatedAt()))
                .toList();
    }

    private String getLocalityStatusForReport(List<Complaint> complaints, boolean inactiveReport) {
        if (complaints == null || complaints.isEmpty()) {
            return "No Reports";
        }

        Complaint latestComplaint = complaints.get(0);
        long daysSince = java.time.temporal.ChronoUnit.DAYS.between(
                latestComplaint.getCreatedAt().toLocalDate(),
                java.time.LocalDate.now()
        );

        return inactiveReport
                ? (daysSince <= 14 ? "Active" : "Inactive")
                : (daysSince <= 14 ? "Active" : "Pending");
    }

    private String getDivisionNameForVillage(Village village) {
        if (village == null) {
            return "N/A";
        }

        Locality locality = localityRepository.findByName(village.getName()).orElse(null);
        if (locality != null && locality.getDivision() != null && locality.getDivision().getName() != null) {
            return locality.getDivision().getName();
        }

        return village.getMandal() != null && village.getMandal().getName() != null
                ? village.getMandal().getName()
                : "N/A";
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/mandal/{id}")
    public String mandalVillages(@PathVariable("id") Long id, Model model) {
        Mandal mandal = mandalRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Mandal not found: " + id));

        List<Village> villages = villageRepository.findByMandal(mandal);

        List<Village> submitted = villages.stream()
                .filter(v -> complaintRepository.countByUserVillage(v) > 0)
                .toList();

        List<Village> notSubmitted = villages.stream()
                .filter(v -> complaintRepository.countByUserVillage(v) == 0)
                .toList();

        java.util.Map<Long, java.time.LocalDateTime> lastSubmissionMap = new java.util.HashMap<>();
        java.util.Map<Long, Long> daysSinceMap = new java.util.HashMap<>();
        for (Village v : villages) {
            List<Complaint> complaints = complaintRepository.findByUserVillage(v);
            if (!complaints.isEmpty()) {
                lastSubmissionMap.put(v.getId(), complaints.get(0).getCreatedAt());
                long daysSince = java.time.temporal.ChronoUnit.DAYS.between(
                        complaints.get(0).getCreatedAt().toLocalDate(),
                        java.time.LocalDate.now()
                );
                daysSinceMap.put(v.getId(), daysSince);
            }
        }

        model.addAttribute("mandal", mandal);
        model.addAttribute("villages", villages);
        model.addAttribute("submitted", submitted);
        model.addAttribute("notSubmitted", notSubmitted);
        model.addAttribute("lastSubmissionMap", lastSubmissionMap);
        model.addAttribute("daysSinceMap", daysSinceMap);
        return "mandal-villages";
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/village/{id}")
    @Transactional(readOnly = true)
    public String villageReport(@PathVariable("id") Long id, Model model) {
        Village village = villageRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Village not found: " + id));

        List<Complaint> complaints = complaintRepository.findByUserVillage(village);
        long userCount = userRepository.countByVillage(village);

        model.addAttribute("village", village);
        model.addAttribute("complaints", complaints);
        model.addAttribute("userCount", userCount);
        if (village.getMandal() != null) {
            model.addAttribute("mandalId", village.getMandal().getId());
        }
        return "village-report";
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/mandal/{id}/reports")
    public String mandalReports(@PathVariable("id") Long id, Model model) {
        Mandal mandal = mandalRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Mandal not found: " + id));

        List<Village> villages = villageRepository.findByMandal(mandal);

        List<Village> submitted = villages.stream()
                .filter(v -> complaintRepository.countByUserVillage(v) > 0)
                .toList();

        List<Village> notSubmitted = villages.stream()
                .filter(v -> complaintRepository.countByUserVillage(v) == 0)
                .toList();

        long totalComplaints = submitted.stream()
                .mapToLong(v -> complaintRepository.countByUserVillage(v))
                .sum();

        long pendingComplaints = notSubmitted.size();

        java.util.Map<Long, List<Complaint>> complainMap = new java.util.HashMap<>();
        for (Village v : submitted) {
            List<Complaint> complaints = complaintRepository.findByUserVillage(v);
            complainMap.put(v.getId(), complaints);
        }

        model.addAttribute("mandal", mandal);
        model.addAttribute("totalVillages", villages.size());
        model.addAttribute("totalComplaints", totalComplaints);
        model.addAttribute("pendingComplaints", pendingComplaints);
        model.addAttribute("submitted", submitted);
        model.addAttribute("notSubmitted", notSubmitted);
        model.addAttribute("complainMap", complainMap);
        return "mandal-reports";
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/reports")
    public String overallReports(
            @RequestParam(value = "division", required = false) Long divisionId,
            @RequestParam(value = "locality", required = false) Long localityId,
            @RequestParam(value = "type", required = false) String type,
            @RequestParam(value = "dateFrom", required = false) String dateFrom,
            @RequestParam(value = "dateTo", required = false) String dateTo,
            Model model) {

        List<Mandal> mandals = mandalRepository.findAll();
        List<Village> allVillages = villageRepository.findAll();
        List<Division> allDivisions = divisionRepository.findAll();

        Specification<Complaint> spec = Specification.where(null);

        if (divisionId != null) {
            Division selectedDivision = divisionRepository.findById(divisionId).orElse(null);
            if (selectedDivision != null) {
                List<Long> matchingVillageIds = new java.util.ArrayList<>();
                for (Locality locality : selectedDivision.getLocalities()) {
                    Village v = villageRepository.findByName(locality.getName()).orElse(null);
                    if (v != null) {
                        matchingVillageIds.add(v.getId());
                    }
                }
                if (!matchingVillageIds.isEmpty()) {
                    List<Long> finalMatchingVillageIds = matchingVillageIds;
                    spec = spec.and((root, query, cb) ->
                        root.get("user").get("village").get("id").in(finalMatchingVillageIds)
                    );
                }
            }
        }

        if (localityId != null) {
            spec = spec.and((root, query, cb) ->
                cb.equal(root.get("user").get("village").get("id"), localityId)
            );
        }

        if (type != null && !type.isBlank()) {
            spec = spec.and((root, query, cb) ->
                cb.equal(cb.lower(root.get("type")), type.toLowerCase())
            );
        }

        if (dateFrom != null && !dateFrom.isBlank()) {
            java.time.LocalDate from = java.time.LocalDate.parse(dateFrom);
            spec = spec.and((root, query, cb) ->
                cb.greaterThanOrEqualTo(root.get("createdAt"), from.atStartOfDay())
            );
        }

        if (dateTo != null && !dateTo.isBlank()) {
            java.time.LocalDate to = java.time.LocalDate.parse(dateTo);
            spec = spec.and((root, query, cb) ->
                cb.lessThanOrEqualTo(root.get("createdAt"), to.plusDays(1).atStartOfDay())
            );
        }

        List<Complaint> filteredComplaints = complaintRepository.findAll(spec);

        long submittedVillages = allVillages.stream()
                .filter(v -> complaintRepository.countByUserVillage(v) > 0)
                .count();
        long pendingVillages = allVillages.size() - submittedVillages;

        long totalComplaints = filteredComplaints.size();
        long pendingComplaints = allVillages.stream()
                .filter(v -> complaintRepository.countByUserVillage(v) == 0)
                .count();

        java.util.Map<String, Long> complaintsByType = filteredComplaints.stream()
                .collect(java.util.stream.Collectors.groupingBy(
                        c -> c.getType() != null ? c.getType() : "UNKNOWN",
                        java.util.stream.Collectors.counting()
                ));

        java.util.Map<String, Long> complaintsByDivision = new java.util.LinkedHashMap<>();
        for (Division division : allDivisions) {
            long count = 0;
            for (Locality locality : division.getLocalities()) {
                Village matchedVillage = allVillages.stream()
                        .filter(v -> locality.getName().equalsIgnoreCase(v.getName()))
                        .findFirst()
                        .orElse(null);
                if (matchedVillage != null) {
                    List<Complaint> vComplaints = filteredComplaints.stream()
                            .filter(c -> c.getUser() != null && c.getUser().getVillage() != null && c.getUser().getVillage().getId().equals(matchedVillage.getId()))
                            .toList();
                    count += vComplaints.size();
                }
            }
            if (count > 0) {
                complaintsByDivision.put(division.getName(), count);
            }
        }
        complaintsByDivision = complaintsByDivision.entrySet().stream()
                .sorted((a, b) -> Long.compare(b.getValue(), a.getValue()))
                .collect(java.util.stream.Collectors.toMap(
                        java.util.Map.Entry::getKey,
                        java.util.Map.Entry::getValue,
                        (e1, e2) -> e1,
                        java.util.LinkedHashMap::new
                ));

        java.util.Map<String, Long> monthlyTrend = new java.util.LinkedHashMap<>();
        java.time.LocalDateTime now = java.time.LocalDateTime.now();
        for (int i = 11; i >= 0; i--) {
            java.time.LocalDateTime monthStart = now.minusMonths(i).withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0);
            java.time.LocalDateTime monthEnd = monthStart.plusMonths(1);
            long count = filteredComplaints.stream()
                    .filter(c -> c.getCreatedAt() != null && !c.getCreatedAt().isBefore(monthStart) && c.getCreatedAt().isBefore(monthEnd))
                    .count();
            monthlyTrend.put(monthStart.format(java.time.format.DateTimeFormatter.ofPattern("MMM yyyy")), count);
        }

        List<Map<String, Object>> topDivisions = new java.util.ArrayList<>();
        for (java.util.Map.Entry<String, Long> entry : complaintsByDivision.entrySet().stream().limit(5).toList()) {
            Map<String, Object> row = new java.util.HashMap<>();
            row.put("name", entry.getKey());
            row.put("count", entry.getValue());
            topDivisions.add(row);
        }

        List<MandalReportItem> submittedDetails = buildSubmittedDetails();
        List<MandalReportItem> pendingDetails = buildPendingDetails();

        model.addAttribute("mandals", mandals);
        model.addAttribute("totalVillages", allVillages.size());
        model.addAttribute("submittedVillages", submittedVillages);
        model.addAttribute("pendingVillages", pendingVillages);
        model.addAttribute("totalComplaints", totalComplaints);
        model.addAttribute("pendingComplaints", pendingComplaints);
        model.addAttribute("complaintsByType", complaintsByType);
        model.addAttribute("submittedDetails", submittedDetails);
        model.addAttribute("pendingDetails", pendingDetails);

        model.addAttribute("complaintsByDivision", complaintsByDivision);
        model.addAttribute("monthlyTrend", monthlyTrend);
        model.addAttribute("topDivisions", topDivisions);

        model.addAttribute("selectedDivisionId", divisionId);
        model.addAttribute("selectedVillageId", localityId);
        model.addAttribute("selectedType", type);
        model.addAttribute("dateFrom", dateFrom);
        model.addAttribute("dateTo", dateTo);

        return "reports";
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/complaints")
    public String adminComplaints(
            @RequestParam(value = "search", required = false) String search,
            @RequestParam(value = "type", required = false) String type,
            @RequestParam(value = "villageId", required = false) Long villageId,
            @RequestParam(value = "complaintId", required = false) String complaintId,
            @RequestParam(value = "submittedBy", required = false) String submittedBy,
            @RequestParam(value = "dateFrom", required = false) String dateFrom,
            @RequestParam(value = "dateTo", required = false) String dateTo,
            Model model) {

        Specification<Complaint> spec = Specification.where(null);

        if (search != null && !search.isBlank()) {
            String term = search.toLowerCase();
            spec = spec.and((root, query, cb) -> {
                String like = "%" + term + "%";
                return cb.or(
                    cb.like(cb.lower(root.get("id").as(String.class)), like),
                    cb.like(cb.lower(root.get("type")), like),
                    cb.like(cb.lower(root.get("user").get("village").get("name")), like)
                );
            });
        }

        if (type != null && !type.isBlank()) {
            spec = spec.and((root, query, cb) ->
                cb.equal(cb.lower(root.get("type")), type.toLowerCase())
            );
        }

        if (villageId != null) {
            spec = spec.and((root, query, cb) ->
                cb.equal(root.get("user").get("village").get("id"), villageId)
            );
        }

        if (complaintId != null && !complaintId.isBlank()) {
            try {
                Long cid = Long.parseLong(complaintId);
                spec = spec.and((root, query, cb) ->
                    cb.equal(root.get("id"), cid)
                );
            } catch (NumberFormatException e) {
                // ignore invalid ID
            }
        }

        if (submittedBy != null && !submittedBy.isBlank()) {
            String term = submittedBy.toLowerCase();
            spec = spec.and((root, query, cb) ->
                cb.like(cb.lower(root.get("user").get("username")), "%" + term + "%")
            );
        }

        if (dateFrom != null && !dateFrom.isBlank()) {
            java.time.LocalDate from = java.time.LocalDate.parse(dateFrom);
            spec = spec.and((root, query, cb) ->
                cb.greaterThanOrEqualTo(root.get("createdAt"), from.atStartOfDay())
            );
        }

        if (dateTo != null && !dateTo.isBlank()) {
            java.time.LocalDate to = java.time.LocalDate.parse(dateTo);
            spec = spec.and((root, query, cb) ->
                cb.lessThanOrEqualTo(root.get("createdAt"), to.plusDays(1).atStartOfDay())
            );
        }

        List<Complaint> complaints = complaintRepository.findAll(spec);

        java.util.List<String> activeFilters = new java.util.ArrayList<>();
        if (type != null && !type.isBlank()) activeFilters.add("Type: " + type);
        if (villageId != null) {
            Village v = villageRepository.findById(villageId).orElse(null);
            if (v != null) activeFilters.add("Division: " + v.getName());
        }
        if (complaintId != null && !complaintId.isBlank()) activeFilters.add("Complaint ID: " + complaintId);
        if (submittedBy != null && !submittedBy.isBlank()) activeFilters.add("Submitted By: " + submittedBy);
        if (dateFrom != null && !dateFrom.isBlank()) activeFilters.add("Date From: " + dateFrom);
        if (dateTo != null && !dateTo.isBlank()) activeFilters.add("Date To: " + dateTo);

        model.addAttribute("complaints", complaints);
        model.addAttribute("search", search);
        model.addAttribute("selectedType", type);
        model.addAttribute("selectedVillageId", villageId);
        model.addAttribute("complaintId", complaintId);
        model.addAttribute("submittedBy", submittedBy);
        model.addAttribute("dateFrom", dateFrom);
        model.addAttribute("dateTo", dateTo);
        model.addAttribute("activeFilters", activeFilters);
        model.addAttribute("villages", villageRepository.findAll());
        model.addAttribute("complaintTypes", List.of(
            "CHILD_MARRIAGE", "POCSO", "CHILD_LABOUR", "SCHOOL_DROPOUTS",
            "CHILD_NEGLIGENCY", "HIV_INFECTION", "ORPHANS", "OTHER"
        ));
        return "admin-complaints";
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/complaints/{id}")
    public String adminComplaintDetail(@PathVariable("id") Long id, Model model) {
        Complaint complaint = complaintRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Complaint not found: " + id));
        model.addAttribute("complaint", complaint);
        return "admin-complaint-detail";
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/reports/export/excel")
    public ResponseEntity<byte[]> exportExcel(@RequestParam String type) throws Exception {
        List<MandalReportItem> items = "submitted".equalsIgnoreCase(type)
                ? buildSubmittedDetails()
                : buildPendingDetails();

        org.apache.poi.ss.usermodel.Workbook wb = new org.apache.poi.xssf.usermodel.XSSFWorkbook();
        org.apache.poi.ss.usermodel.Sheet sheet = wb.createSheet(type + "_villages");

        org.apache.poi.ss.usermodel.Row header = sheet.createRow(0);
        String[] cols = "submitted".equalsIgnoreCase(type)
                ? new String[]{"Village Name", "Mandal Name", "Submitted Date", "Submitted Time"}
                : new String[]{"Village Name", "Mandal Name"};
        for (int i = 0; i < cols.length; i++) {
            org.apache.poi.ss.usermodel.Cell cell = header.createCell(i);
            cell.setCellValue(cols[i]);
            cell.setCellStyle(getHeaderStyle(wb));
        }

        for (int i = 0; i < items.size(); i++) {
            org.apache.poi.ss.usermodel.Row row = sheet.createRow(i + 1);
            MandalReportItem item = items.get(i);
            row.createCell(0).setCellValue(item.getVillageName() != null ? item.getVillageName() : "");
            row.createCell(1).setCellValue(item.getMandalName() != null ? item.getMandalName() : "");
            if ("submitted".equalsIgnoreCase(type)) {
                row.createCell(2).setCellValue(item.getSubmittedDate() != null ? item.getSubmittedDate() : "");
                row.createCell(3).setCellValue(item.getSubmittedTime() != null ? item.getSubmittedTime() : "");
            }
        }

        for (int i = 0; i < cols.length; i++) {
            int width = "submitted".equalsIgnoreCase(type)
                    ? new int[]{35, 30, 18, 18}[i]
                    : 30;
            sheet.setColumnWidth(i, width * 256);
        }

        ByteArrayOutputStream out = new ByteArrayOutputStream();
        wb.write(out);
        wb.close();

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        headers.setContentDispositionFormData("attachment", "reports_" + type + ".xlsx");
        headers.setContentLength(out.size());

        return ResponseEntity.ok().headers(headers).body(out.toByteArray());
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/reports/export/pdf")
    public ResponseEntity<byte[]> exportPdf(@RequestParam String type) throws Exception {
        List<MandalReportItem> items = "submitted".equalsIgnoreCase(type)
                ? buildSubmittedDetails()
                : buildPendingDetails();

        com.lowagie.text.Document document = new com.lowagie.text.Document(com.lowagie.text.PageSize.A4);
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        com.lowagie.text.pdf.PdfWriter.getInstance(document, out);
        document.open();

        com.lowagie.text.Font titleFont = new com.lowagie.text.Font(com.lowagie.text.Font.HELVETICA, 16, com.lowagie.text.Font.BOLD);
        com.lowagie.text.Font headerFont = new com.lowagie.text.Font(com.lowagie.text.Font.HELVETICA, 12, com.lowagie.text.Font.BOLD);
        com.lowagie.text.Font bodyFont = new com.lowagie.text.Font(com.lowagie.text.Font.HELVETICA, 10, com.lowagie.text.Font.NORMAL);

        document.add(new com.lowagie.text.Paragraph(type.toUpperCase() + " VILLAGES REPORT", titleFont));
        document.add(new com.lowagie.text.Paragraph(" "));

        com.lowagie.text.pdf.PdfPTable table = new com.lowagie.text.pdf.PdfPTable("submitted".equalsIgnoreCase(type) ? 4 : 2);
        table.setWidthPercentage(100);
        table.setSpacingBefore(10f);
        table.setSpacingAfter(10f);

        String[] headers = "submitted".equalsIgnoreCase(type)
                ? new String[]{"Village Name", "Mandal Name", "Submitted Date", "Submitted Time"}
                : new String[]{"Village Name", "Mandal Name"};
        for (String h : headers) {
            table.addCell(new com.lowagie.text.Phrase(h, headerFont));
        }

        for (MandalReportItem item : items) {
            table.addCell(new com.lowagie.text.Phrase(item.getVillageName() != null ? item.getVillageName() : "", bodyFont));
            table.addCell(new com.lowagie.text.Phrase(item.getMandalName() != null ? item.getMandalName() : "", bodyFont));
            if ("submitted".equalsIgnoreCase(type)) {
                table.addCell(new com.lowagie.text.Phrase(item.getSubmittedDate() != null ? item.getSubmittedDate() : "", bodyFont));
                table.addCell(new com.lowagie.text.Phrase(item.getSubmittedTime() != null ? item.getSubmittedTime() : "", bodyFont));
            }
        }

        document.add(table);
        document.close();

        HttpHeaders httpHeaders = new HttpHeaders();
        httpHeaders.setContentType(MediaType.APPLICATION_PDF);
        httpHeaders.setContentDispositionFormData("attachment", "reports_" + type + ".pdf");
        httpHeaders.setContentLength(out.size());

        return ResponseEntity.ok().headers(httpHeaders).body(out.toByteArray());
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/reports/details")
    public String reportDetails(
            @RequestParam("type") String type,
            @RequestParam(value = "division", required = false) Long divisionId,
            @RequestParam(value = "locality", required = false) Long localityId,
            @RequestParam(value = "filterType", required = false) String filterType,
            @RequestParam(value = "dateFrom", required = false) String dateFrom,
            @RequestParam(value = "dateTo", required = false) String dateTo,
            Model model) {
        model.addAttribute("reportType", type);
        model.addAttribute("exportBase", "report_details");
        model.addAttribute("selectedDivisionId", divisionId);
        model.addAttribute("selectedVillageId", localityId);
        model.addAttribute("selectedType", filterType);
        model.addAttribute("dateFrom", dateFrom);
        model.addAttribute("dateTo", dateTo);

        Specification<Complaint> spec = Specification.where(null);

        if (divisionId != null) {
            Division selectedDivision = divisionRepository.findById(divisionId).orElse(null);
            if (selectedDivision != null) {
                List<Long> matchingVillageIds = new java.util.ArrayList<>();
                for (Locality locality : selectedDivision.getLocalities()) {
                    Village v = villageRepository.findByName(locality.getName()).orElse(null);
                    if (v != null) {
                        matchingVillageIds.add(v.getId());
                    }
                }
                if (!matchingVillageIds.isEmpty()) {
                    List<Long> finalMatchingVillageIds = matchingVillageIds;
                    spec = spec.and((root, query, cb) ->
                        root.get("user").get("village").get("id").in(finalMatchingVillageIds)
                    );
                }
            }
        }

        if (localityId != null) {
            spec = spec.and((root, query, cb) ->
                cb.equal(root.get("user").get("village").get("id"), localityId)
            );
        }

        if (filterType != null && !filterType.isBlank()) {
            spec = spec.and((root, query, cb) ->
                cb.equal(cb.lower(root.get("type")), filterType.toLowerCase())
            );
        }

                if (dateFrom != null && !dateFrom.isBlank()) {
            java.time.LocalDate from = java.time.LocalDate.parse(dateFrom);
            spec = spec.and((root, query, cb) ->
                cb.greaterThanOrEqualTo(root.get("createdAt"), from.atStartOfDay())
            );
        }

        if (dateTo != null && !dateTo.isBlank()) {
            java.time.LocalDate to = java.time.LocalDate.parse(dateTo);
            spec = spec.and((root, query, cb) ->
                cb.lessThanOrEqualTo(root.get("createdAt"), to.plusDays(1).atStartOfDay())
            );
        }

        List<Complaint> filteredComplaints = complaintRepository.findAll(spec);

        switch (type.toUpperCase()) {
            case "TOTAL" -> {
                model.addAttribute("complaints", filteredComplaints);
                model.addAttribute("pageTitle", "Total Complaints");
            }
            case "PENDING" -> {
                List<Village> pendingVillages = villageRepository.findAll().stream()
                        .filter(v -> complaintRepository.countByUserVillage(v) == 0)
                        .toList();
                model.addAttribute("pendingVillages", pendingVillages);
                model.addAttribute("pageTitle", "Pending Villages");
            }
            case "MAJOR" -> {
                List<Complaint> major = filteredComplaints.stream()
                        .filter(c -> "HIGH".equalsIgnoreCase(c.getType()) || "CRITICAL".equalsIgnoreCase(c.getType()))
                        .toList();
                model.addAttribute("complaints", major);
                model.addAttribute("pageTitle", "Major Cases");
            }
            case "RECENT" -> {
                LocalDateTime sevenDaysAgo = LocalDateTime.now().minusDays(7);
                List<Complaint> recent = filteredComplaints.stream()
                        .filter(c -> c.getCreatedAt() != null && !c.getCreatedAt().isBefore(sevenDaysAgo))
                        .toList();
                model.addAttribute("complaints", recent);
                model.addAttribute("pageTitle", "Last 7 Days Complaints");
            }
            case "CRITICAL" -> {
                List<Complaint> critical = filteredComplaints.stream()
                        .filter(c -> "CRITICAL".equalsIgnoreCase(c.getPriority()))
                        .toList();
                model.addAttribute("complaints", critical);
                model.addAttribute("pageTitle", "Critical Complaints");
            }
            case "PENDING_LOCALITIES" -> {
                List<Village> allVillages = villageRepository.findAll();
                List<Map<String, Object>> pendingLocalities = new ArrayList<>();
                for (Village v : allVillages) {
                    List<Complaint> vComplaints = getLatestComplaintsForVillage(v);
                    Map<String, Object> row = new java.util.HashMap<>();
                    row.put("village", v);
                    row.put("divisionName", getDivisionNameForVillage(v));
                    if (!vComplaints.isEmpty()) {
                        Complaint latestComplaint = vComplaints.get(0);
                        row.put("lastReportDate", latestComplaint.getCreatedAt());
                        long daysSince = java.time.temporal.ChronoUnit.DAYS.between(
                                latestComplaint.getCreatedAt().toLocalDate(),
                                java.time.LocalDate.now()
                        );
                        row.put("daysSince", daysSince);
                        row.put("status", getLocalityStatusForReport(vComplaints, false));
                        if (daysSince > 14) {
                            pendingLocalities.add(row);
                        }
                    } else {
                        row.put("lastReportDate", null);
                        row.put("daysSince", null);
                        row.put("status", "No Reports");
                        pendingLocalities.add(row);
                    }
                }
                model.addAttribute("pendingLocalities", pendingLocalities);
                model.addAttribute("pageTitle", "Pending Localities");
            }
default -> {
                model.addAttribute("complaints", List.of());
                model.addAttribute("pageTitle", "Unknown Report");
            }
        }
        return "report-details";
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/reports/export/details/excel")
    public ResponseEntity<byte[]> exportDetailsExcel(
            @RequestParam String type,
            @RequestParam(value = "division", required = false) Long divisionId,
            @RequestParam(value = "locality", required = false) Long localityId,
            @RequestParam(value = "complaintType", required = false) String complaintType,
            @RequestParam(value = "dateFrom", required = false) String dateFrom,
            @RequestParam(value = "dateTo", required = false) String dateTo) throws Exception {

        Specification<Complaint> spec = Specification.where(null);

        if (divisionId != null) {
            Division selectedDivision = divisionRepository.findById(divisionId).orElse(null);
            if (selectedDivision != null) {
                List<Long> matchingVillageIds = new java.util.ArrayList<>();
                for (Locality locality : selectedDivision.getLocalities()) {
                    Village v = villageRepository.findByName(locality.getName()).orElse(null);
                    if (v != null) {
                        matchingVillageIds.add(v.getId());
                    }
                }
                if (!matchingVillageIds.isEmpty()) {
                    List<Long> finalMatchingVillageIds = matchingVillageIds;
                    spec = spec.and((root, query, cb) ->
                        root.get("user").get("village").get("id").in(finalMatchingVillageIds)
                    );
                }
            }
        }

        if (localityId != null) {
            spec = spec.and((root, query, cb) ->
                cb.equal(root.get("user").get("village").get("id"), localityId)
            );
        }

        if (complaintType != null && !complaintType.isBlank()) {
            spec = spec.and((root, query, cb) ->
                cb.equal(cb.lower(root.get("type")), complaintType.toLowerCase())
            );
        }

                if (dateFrom != null && !dateFrom.isBlank()) {
            java.time.LocalDate from = java.time.LocalDate.parse(dateFrom);
            spec = spec.and((root, query, cb) ->
                cb.greaterThanOrEqualTo(root.get("createdAt"), from.atStartOfDay())
            );
        }

        if (dateTo != null && !dateTo.isBlank()) {
            java.time.LocalDate to = java.time.LocalDate.parse(dateTo);
            spec = spec.and((root, query, cb) ->
                cb.lessThanOrEqualTo(root.get("createdAt"), to.plusDays(1).atStartOfDay())
            );
        }

        List<Complaint> filteredComplaints = complaintRepository.findAll(spec);

        List<String[]> rows = new ArrayList<>();
        String fileName = "report_" + type;

        switch (type.toUpperCase()) {
            case "TOTAL", "MAJOR", "RECENT", "CRITICAL" -> {
                List<Complaint> complaints = filteredComplaints;
                if ("MAJOR".equalsIgnoreCase(type)) {
                    complaints = filteredComplaints.stream()
                            .filter(c -> "HIGH".equalsIgnoreCase(c.getType()) || "CRITICAL".equalsIgnoreCase(c.getType()))
                            .toList();
                } else if ("RECENT".equalsIgnoreCase(type)) {
                    LocalDateTime sevenDaysAgo = LocalDateTime.now().minusDays(7);
                    complaints = filteredComplaints.stream()
                            .filter(c -> c.getCreatedAt() != null && !c.getCreatedAt().isBefore(sevenDaysAgo))
                            .toList();
                } else if ("CRITICAL".equalsIgnoreCase(type)) {
                    complaints = filteredComplaints.stream()
                            .filter(c -> "CRITICAL".equalsIgnoreCase(c.getPriority()))
                            .toList();
                }
                rows.add(new String[]{"ID", "Type", "Locality", "Mandal", "Submitted By", "Priority", "Created Date"});
                for (Complaint c : complaints) {
                    String mandalName = c.getUser() != null && c.getUser().getVillage() != null &&
                            c.getUser().getVillage().getMandal() != null
                            ? c.getUser().getVillage().getMandal().getName() : "N/A";
                    rows.add(new String[]{
                            String.valueOf(c.getId()),
                            c.getType() != null ? c.getType() : "",
                            c.getUser() != null && c.getUser().getVillage() != null ? c.getUser().getVillage().getName() : "",
                            mandalName,
                            c.getUser() != null ? c.getUser().getUsername() : "",
                            
                            c.getCreatedAt() != null ? c.getCreatedAt().toString() : ""
                    });
                }
            }
            case "PENDING" -> {
                List<Village> pendingVillages = villageRepository.findAll().stream()
                        .filter(v -> complaintRepository.countByUserVillage(v) == 0)
                        .toList();
                rows.add(new String[]{"Village Name", "Mandal Name", "Status"});
                for (Village v : pendingVillages) {
                    rows.add(new String[]{
                            v.getName(),
                            v.getMandal() != null ? v.getMandal().getName() : "N/A",
                            "Pending"
                    });
                }
            }
            case "PENDING_LOCALITIES", "INACTIVE_LOCALITIES" -> {
                List<Village> allVillages = villageRepository.findAll();
                rows.add(new String[]{"Locality Name", "Division Name", "Last Report Date", "Days Since Last Report", "Status"});
                boolean inactiveReport = "INACTIVE_LOCALITIES".equalsIgnoreCase(type);
                for (Village v : allVillages) {
                    String divisionName = getDivisionNameForVillage(v);
                    List<Complaint> vComplaints = getLatestComplaintsForVillage(v);
                    if (vComplaints.isEmpty()) {
                        rows.add(new String[]{
                                v.getName(),
                                divisionName,
                                "",
                                "",
                                "No Reports"
                        });
                    } else {
                        LocalDateTime lastDate = vComplaints.get(0).getCreatedAt();
                        long daysSince = java.time.temporal.ChronoUnit.DAYS.between(
                                lastDate.toLocalDate(), java.time.LocalDate.now()
                        );
                        String status = getLocalityStatusForReport(vComplaints, inactiveReport);
                        rows.add(new String[]{
                                v.getName(),
                                divisionName,
                                lastDate.toString(),
                                String.valueOf(daysSince),
                                status
                        });
                    }
                }
            }
            default -> {
                rows.add(new String[]{"No data"});
            }
        }

        List<String[]> exportRows = new ArrayList<>();
        exportRows.add(new String[]{"Generated: " + java.time.LocalDateTime.now().toString()});
        exportRows.add(new String[]{"Total Records: " + (rows.size() - 1)});
        exportRows.add(new String[]{""});

        java.util.List<String> activeFilters = new java.util.ArrayList<>();
        if (divisionId != null) activeFilters.add("Division: " + (divisionRepository.findById(divisionId).orElse(null) != null ? divisionRepository.findById(divisionId).get().getName() : ""));
        if (localityId != null) activeFilters.add("Locality: " + (villageRepository.findById(localityId).orElse(null) != null ? villageRepository.findById(localityId).get().getName() : ""));
        if (complaintType != null && !complaintType.isBlank()) activeFilters.add("Type: " + complaintType);
        if (dateFrom != null && !dateFrom.isBlank()) activeFilters.add("Date From: " + dateFrom);
        if (dateTo != null && !dateTo.isBlank()) activeFilters.add("Date To: " + dateTo);

        if (!activeFilters.isEmpty()) {
            exportRows.add(new String[]{"Applied Filters:"});
            for (String filter : activeFilters) {
                exportRows.add(new String[]{"  " + filter});
            }
            exportRows.add(new String[]{""});
        }

        for (String[] row : rows) {
            exportRows.add(row);
        }

        org.apache.poi.ss.usermodel.Workbook wb = new org.apache.poi.xssf.usermodel.XSSFWorkbook();
        org.apache.poi.ss.usermodel.Sheet sheet = wb.createSheet(fileName);

        for (int i = 0; i < exportRows.size(); i++) {
            org.apache.poi.ss.usermodel.Row row = sheet.createRow(i);
            String[] cols = exportRows.get(i);
            for (int j = 0; j < cols.length; j++) {
                row.createCell(j).setCellValue(cols[j] != null ? cols[j] : "");
            }
        }

        for (int i = 0; i < exportRows.get(0).length; i++) {
            sheet.setColumnWidth(i, 25 * 256);
        }

        ByteArrayOutputStream out = new ByteArrayOutputStream();
        wb.write(out);
        wb.close();

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        headers.setContentDispositionFormData("attachment", fileName + ".xlsx");
        headers.setContentLength(out.size());

        return ResponseEntity.ok().headers(headers).body(out.toByteArray());
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/reports/export/details/pdf")
    public ResponseEntity<byte[]> exportDetailsPdf(
            @RequestParam String type,
            @RequestParam(value = "division", required = false) Long divisionId,
            @RequestParam(value = "locality", required = false) Long localityId,
            @RequestParam(value = "type", required = false) String filterType,
            @RequestParam(value = "dateFrom", required = false) String dateFrom,
            @RequestParam(value = "dateTo", required = false) String dateTo) throws Exception {

        Specification<Complaint> spec = Specification.where(null);

        if (divisionId != null) {
            Division selectedDivision = divisionRepository.findById(divisionId).orElse(null);
            if (selectedDivision != null) {
                List<Long> matchingVillageIds = new java.util.ArrayList<>();
                for (Locality locality : selectedDivision.getLocalities()) {
                    Village v = villageRepository.findByName(locality.getName()).orElse(null);
                    if (v != null) {
                        matchingVillageIds.add(v.getId());
                    }
                }
                if (!matchingVillageIds.isEmpty()) {
                    List<Long> finalMatchingVillageIds = matchingVillageIds;
                    spec = spec.and((root, query, cb) ->
                        root.get("user").get("village").get("id").in(finalMatchingVillageIds)
                    );
                }
            }
        }

        if (localityId != null) {
            spec = spec.and((root, query, cb) ->
                cb.equal(root.get("user").get("village").get("id"), localityId)
            );
        }

        if (filterType != null && !filterType.isBlank()) {
            spec = spec.and((root, query, cb) ->
                cb.equal(cb.lower(root.get("type")), filterType.toLowerCase())
            );
        }

                if (dateFrom != null && !dateFrom.isBlank()) {
            java.time.LocalDate from = java.time.LocalDate.parse(dateFrom);
            spec = spec.and((root, query, cb) ->
                cb.greaterThanOrEqualTo(root.get("createdAt"), from.atStartOfDay())
            );
        }

        if (dateTo != null && !dateTo.isBlank()) {
            java.time.LocalDate to = java.time.LocalDate.parse(dateTo);
            spec = spec.and((root, query, cb) ->
                cb.lessThanOrEqualTo(root.get("createdAt"), to.plusDays(1).atStartOfDay())
            );
        }

        List<Complaint> filteredComplaints = complaintRepository.findAll(spec);

        String fileName = "report_" + type;
        String title = "REPORT: " + type.toUpperCase();

        com.lowagie.text.Document document = new com.lowagie.text.Document(com.lowagie.text.PageSize.A4);
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        com.lowagie.text.pdf.PdfWriter.getInstance(document, out);
        document.open();

        com.lowagie.text.Font titleFont = new com.lowagie.text.Font(com.lowagie.text.Font.HELVETICA, 16, com.lowagie.text.Font.BOLD);
        document.add(new com.lowagie.text.Paragraph(title, titleFont));
        document.add(new com.lowagie.text.Paragraph("Generated: " + java.time.LocalDateTime.now().toString()));
        document.add(new com.lowagie.text.Paragraph(" "));

        java.util.List<String> activeFilters = new java.util.ArrayList<>();
        if (divisionId != null) activeFilters.add("Division: " + (divisionRepository.findById(divisionId).orElse(null) != null ? divisionRepository.findById(divisionId).get().getName() : ""));
        if (localityId != null) activeFilters.add("Locality: " + (villageRepository.findById(localityId).orElse(null) != null ? villageRepository.findById(localityId).get().getName() : ""));
        if (filterType != null && !filterType.isBlank()) activeFilters.add("Type: " + filterType);
        if (dateFrom != null && !dateFrom.isBlank()) activeFilters.add("Date From: " + dateFrom);
        if (dateTo != null && !dateTo.isBlank()) activeFilters.add("Date To: " + dateTo);

        if (!activeFilters.isEmpty()) {
            com.lowagie.text.Font filterFont = new com.lowagie.text.Font(com.lowagie.text.Font.HELVETICA, 9, com.lowagie.text.Font.ITALIC);
            document.add(new com.lowagie.text.Paragraph("Applied Filters:", filterFont));
            for (String filter : activeFilters) {
                document.add(new com.lowagie.text.Paragraph("  " + filter, filterFont));
            }
            document.add(new com.lowagie.text.Paragraph(" "));
        }

        int columns = 0;
        List<String[]> rows = new ArrayList<>();

        switch (type.toUpperCase()) {
            case "TOTAL", "MAJOR", "RECENT", "CRITICAL" -> {
                List<Complaint> complaints = filteredComplaints;
                if ("MAJOR".equalsIgnoreCase(type)) {
                    complaints = filteredComplaints.stream()
                            .filter(c -> "HIGH".equalsIgnoreCase(c.getType()) || "CRITICAL".equalsIgnoreCase(c.getType()))
                            .toList();
                } else if ("RECENT".equalsIgnoreCase(type)) {
                    LocalDateTime sevenDaysAgo = LocalDateTime.now().minusDays(7);
                    complaints = filteredComplaints.stream()
                            .filter(c -> c.getCreatedAt() != null && !c.getCreatedAt().isBefore(sevenDaysAgo))
                            .toList();
                } else if ("CRITICAL".equalsIgnoreCase(type)) {
                    complaints = filteredComplaints.stream()
                            .filter(c -> "CRITICAL".equalsIgnoreCase(c.getPriority()))
                            .toList();
                }
                columns = 7;
                rows.add(new String[]{"ID", "Type", "Locality", "Mandal", "Submitted By", "Priority", "Created Date"});
                for (Complaint c : complaints) {
                    String mandalName = c.getUser() != null && c.getUser().getVillage() != null &&
                            c.getUser().getVillage().getMandal() != null
                            ? c.getUser().getVillage().getMandal().getName() : "N/A";
                    rows.add(new String[]{
                            String.valueOf(c.getId()),
                            c.getType() != null ? c.getType() : "",
                            c.getUser() != null && c.getUser().getVillage() != null ? c.getUser().getVillage().getName() : "",
                            mandalName,
                            c.getUser() != null ? c.getUser().getUsername() : "",
                            
                            c.getCreatedAt() != null ? c.getCreatedAt().toString() : ""
                    });
                }
            }
            case "PENDING" -> {
                columns = 3;
                List<Village> pendingVillages = villageRepository.findAll().stream()
                        .filter(v -> complaintRepository.countByUserVillage(v) == 0)
                        .toList();
                rows.add(new String[]{"Village Name", "Mandal Name", "Status"});
                for (Village v : pendingVillages) {
                    rows.add(new String[]{
                            v.getName(),
                            v.getMandal() != null ? v.getMandal().getName() : "N/A",
                            "Pending"
                    });
                }
            }
            case "PENDING_LOCALITIES", "INACTIVE_LOCALITIES" -> {
                columns = 5;
                List<Village> allVillages = villageRepository.findAll();
                rows.add(new String[]{"Locality Name", "Mandal Name", "Last Report Date", "Days Since Last Report", "Status"});
                boolean inactiveReport = "INACTIVE_LOCALITIES".equalsIgnoreCase(type);
                for (Village v : allVillages) {
                    List<Complaint> vComplaints = getLatestComplaintsForVillage(v);
                    if (vComplaints.isEmpty()) {
                        rows.add(new String[]{
                                v.getName(),
                                v.getMandal() != null ? v.getMandal().getName() : "N/A",
                                "",
                                "",
                                "No Reports"
                        });
                    } else {
                        LocalDateTime lastDate = vComplaints.get(0).getCreatedAt();
                        long daysSince = java.time.temporal.ChronoUnit.DAYS.between(
                                lastDate.toLocalDate(), java.time.LocalDate.now()
                        );
                        String status = getLocalityStatusForReport(vComplaints, inactiveReport);
                        rows.add(new String[]{
                                v.getName(),
                                v.getMandal() != null ? v.getMandal().getName() : "N/A",
                                lastDate.toString(),
                                String.valueOf(daysSince),
                                status
                        });
                    }
                }
            }
            default -> {
                columns = 1;
                rows.add(new String[]{"No data"});
            }
        }

        document.add(new com.lowagie.text.Paragraph("Total Records: " + (rows.size() - 1)));
        document.add(new com.lowagie.text.Paragraph(" "));

        com.lowagie.text.pdf.PdfPTable table = new com.lowagie.text.pdf.PdfPTable(columns);
        table.setWidthPercentage(100);
        table.setSpacingBefore(10f);
        table.setSpacingAfter(10f);

        com.lowagie.text.Font headerFont = new com.lowagie.text.Font(com.lowagie.text.Font.HELVETICA, 10, com.lowagie.text.Font.BOLD);
        com.lowagie.text.Font bodyFont = new com.lowagie.text.Font(com.lowagie.text.Font.HELVETICA, 9, com.lowagie.text.Font.NORMAL);

        String[] headers = rows.get(0);
        for (String h : headers) {
            table.addCell(new com.lowagie.text.Phrase(h, headerFont));
        }

        for (int i = 1; i < rows.size(); i++) {
            String[] row = rows.get(i);
            for (String cell : row) {
                table.addCell(new com.lowagie.text.Phrase(cell != null ? cell : "", bodyFont));
            }
        }

        document.add(table);
        document.close();

        HttpHeaders httpHeaders = new HttpHeaders();
        httpHeaders.setContentType(MediaType.APPLICATION_PDF);
        httpHeaders.setContentDispositionFormData("attachment", fileName + ".pdf");
        httpHeaders.setContentLength(out.size());

        return ResponseEntity.ok().headers(httpHeaders).body(out.toByteArray());
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/division/{id}/export/excel")
    public ResponseEntity<byte[]> exportDivisionExcel(@PathVariable("id") Long id) throws Exception {
        Division division = divisionRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Division not found: " + id));

        List<Locality> localities = division.getLocalities();
        localities.sort((a, b) -> {
            String statusA = getLocalityStatus(a, new java.util.HashMap<>(), new java.util.HashMap<>(), new java.util.HashMap<>());
            String statusB = getLocalityStatus(b, new java.util.HashMap<>(), new java.util.HashMap<>(), new java.util.HashMap<>());
            int orderA = switch (statusA) { case "No Reports" -> 0; case "Pending" -> 1; case "Active" -> 2; default -> 3; };
            int orderB = switch (statusB) { case "No Reports" -> 0; case "Pending" -> 1; case "Active" -> 2; default -> 3; };
            return Integer.compare(orderA, orderB);
        });

        org.apache.poi.ss.usermodel.Workbook wb = new org.apache.poi.xssf.usermodel.XSSFWorkbook();
        org.apache.poi.ss.usermodel.Sheet sheet = wb.createSheet(division.getName() + "_localities");

        org.apache.poi.ss.usermodel.Row header = sheet.createRow(0);
        String[] cols = {"Locality Name", "Last Submission", "Status", "Complaints"};
        for (int i = 0; i < cols.length; i++) {
            org.apache.poi.ss.usermodel.Cell cell = header.createCell(i);
            cell.setCellValue(cols[i]);
            cell.setCellStyle(getHeaderStyle(wb));
        }

        int rowIdx = 1;
        for (Locality locality : localities) {
            org.apache.poi.ss.usermodel.Row row = sheet.createRow(rowIdx++);
            Village matchedVillage = villageRepository.findByName(locality.getName()).orElse(null);
            List<Complaint> vComplaints = matchedVillage != null ? complaintRepository.findByUserVillage(matchedVillage) : List.of();
            String lastSubmission = vComplaints.isEmpty() ? "" : vComplaints.get(0).getCreatedAt().toString();
            String status = getLocalityStatus(locality, new java.util.HashMap<>(), new java.util.HashMap<>(), new java.util.HashMap<>());
            row.createCell(0).setCellValue(locality.getName());
            row.createCell(1).setCellValue(lastSubmission);
            row.createCell(2).setCellValue(status);
            row.createCell(3).setCellValue(vComplaints.size());
        }

        for (int i = 0; i < cols.length; i++) {
            sheet.setColumnWidth(i, 25 * 256);
        }

        ByteArrayOutputStream out = new ByteArrayOutputStream();
        wb.write(out);
        wb.close();

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        headers.setContentDispositionFormData("attachment", division.getName() + "_localities.xlsx");
        headers.setContentLength(out.size());

        return ResponseEntity.ok().headers(headers).body(out.toByteArray());
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/division/{id}/export/pdf")
    public ResponseEntity<byte[]> exportDivisionPdf(@PathVariable("id") Long id) throws Exception {
        Division division = divisionRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Division not found: " + id));

        List<Locality> localities = division.getLocalities();
        localities.sort((a, b) -> {
            String statusA = getLocalityStatus(a, new java.util.HashMap<>(), new java.util.HashMap<>(), new java.util.HashMap<>());
            String statusB = getLocalityStatus(b, new java.util.HashMap<>(), new java.util.HashMap<>(), new java.util.HashMap<>());
            int orderA = switch (statusA) { case "No Reports" -> 0; case "Pending" -> 1; case "Active" -> 2; default -> 3; };
            int orderB = switch (statusB) { case "No Reports" -> 0; case "Pending" -> 1; case "Active" -> 2; default -> 3; };
            return Integer.compare(orderA, orderB);
        });

        com.lowagie.text.Document document = new com.lowagie.text.Document(com.lowagie.text.PageSize.A4);
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        com.lowagie.text.pdf.PdfWriter.getInstance(document, out);
        document.open();

        com.lowagie.text.Font titleFont = new com.lowagie.text.Font(com.lowagie.text.Font.HELVETICA, 16, com.lowagie.text.Font.BOLD);
        document.add(new com.lowagie.text.Paragraph("DIVISION: " + division.getName().toUpperCase(), titleFont));
        document.add(new com.lowagie.text.Paragraph("Type: " + division.getType()));
        document.add(new com.lowagie.text.Paragraph("Total Localities: " + localities.size()));
        document.add(new com.lowagie.text.Paragraph(" "));

        com.lowagie.text.pdf.PdfPTable table = new com.lowagie.text.pdf.PdfPTable(4);
        table.setWidthPercentage(100);
        table.setSpacingBefore(10f);
        table.setSpacingAfter(10f);

        com.lowagie.text.Font headerFont = new com.lowagie.text.Font(com.lowagie.text.Font.HELVETICA, 10, com.lowagie.text.Font.BOLD);
        com.lowagie.text.Font bodyFont = new com.lowagie.text.Font(com.lowagie.text.Font.HELVETICA, 9, com.lowagie.text.Font.NORMAL);

        table.addCell(new com.lowagie.text.Phrase("Locality Name", headerFont));
        table.addCell(new com.lowagie.text.Phrase("Last Submission", headerFont));
        table.addCell(new com.lowagie.text.Phrase("Status", headerFont));
        table.addCell(new com.lowagie.text.Phrase("Complaints", headerFont));

        for (Locality locality : localities) {
            Village matchedVillage = villageRepository.findByName(locality.getName()).orElse(null);
            List<Complaint> vComplaints = matchedVillage != null ? complaintRepository.findByUserVillage(matchedVillage) : List.of();
            String lastSubmission = vComplaints.isEmpty() ? "" : vComplaints.get(0).getCreatedAt().toString();
            String status = getLocalityStatus(locality, new java.util.HashMap<>(), new java.util.HashMap<>(), new java.util.HashMap<>());

            table.addCell(new com.lowagie.text.Phrase(locality.getName(), bodyFont));
            table.addCell(new com.lowagie.text.Phrase(lastSubmission, bodyFont));
            table.addCell(new com.lowagie.text.Phrase(status, bodyFont));
            table.addCell(new com.lowagie.text.Phrase(String.valueOf(vComplaints.size()), bodyFont));
        }

        document.add(table);
        document.close();

        HttpHeaders httpHeaders = new HttpHeaders();
        httpHeaders.setContentType(MediaType.APPLICATION_PDF);
        httpHeaders.setContentDispositionFormData("attachment", division.getName() + "_localities.pdf");
        httpHeaders.setContentLength(out.size());

        return ResponseEntity.ok().headers(httpHeaders).body(out.toByteArray());
    }

    private org.apache.poi.ss.usermodel.CellStyle getHeaderStyle(org.apache.poi.ss.usermodel.Workbook wb) {
        org.apache.poi.ss.usermodel.CellStyle style = wb.createCellStyle();
        org.apache.poi.ss.usermodel.Font font = wb.createFont();
        font.setBold(true);
        font.setColor(org.apache.poi.ss.usermodel.IndexedColors.WHITE.getIndex());
        style.setFont(font);
        style.setFillForegroundColor(org.apache.poi.ss.usermodel.IndexedColors.DARK_BLUE.getIndex());
        style.setFillPattern(org.apache.poi.ss.usermodel.FillPatternType.SOLID_FOREGROUND);
        return style;
    }

    private List<MandalReportItem> buildSubmittedDetails() {
        List<Village> allVillages = villageRepository.findAll();
        return allVillages.stream()
                .filter(v -> complaintRepository.countByUserVillage(v) > 0)
                .map(v -> {
                    List<Complaint> complaints = complaintRepository.findByUserVillage(v);
                    Complaint latest = complaints.get(0);
                    String date = null;
                    String time = null;
                    if (latest.getCreatedAt() != null) {
                        LocalDateTime dt = latest.getCreatedAt();
                        date = dt.toLocalDate().toString();
                        time = dt.toLocalTime().format(DateTimeFormatter.ofPattern("HH:mm:ss"));
                    }
                    return new MandalReportItem(
                            v.getName(),
                            v.getMandal() != null ? v.getMandal().getName() : "N/A",
                            date,
                            time
                    );
                })
                .toList();
    }

    private List<MandalReportItem> buildPendingDetails() {
        List<Village> allVillages = villageRepository.findAll();
        return allVillages.stream()
                .filter(v -> complaintRepository.countByUserVillage(v) == 0)
                .map(v -> new MandalReportItem(
                        v.getName(),
                        v.getMandal() != null ? v.getMandal().getName() : "N/A",
                        null,
                        null
                ))
                .toList();
    }
}

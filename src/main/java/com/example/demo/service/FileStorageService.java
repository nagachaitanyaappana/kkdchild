package com.example.demo.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.*;
import java.nio.file.*;
import java.util.UUID;

@Service
public class FileStorageService {

    private final Path uploadDir;

    public FileStorageService(@Value("${file.upload-dir}") String uploadDirPath) throws IOException {
        this.uploadDir = Paths.get(uploadDirPath);
        if (!Files.exists(uploadDir)) {
            Files.createDirectories(uploadDir);
        }
    }

    public String store(MultipartFile file) throws IOException {
        String originalName = StringUtils.cleanPath(file.getOriginalFilename());
        String extension = "";
        int dotIndex = originalName.lastIndexOf('.');
        if (dotIndex >= 0) {
            extension = originalName.substring(dotIndex);
        }
        String fileName = UUID.randomUUID() + extension;
        Path filePath = this.uploadDir.resolve(fileName).normalize();
        try (InputStream is = file.getInputStream()) {
            Files.copy(is, filePath, StandardCopyOption.REPLACE_EXISTING);
        }
        return filePath.toString();
    }
}
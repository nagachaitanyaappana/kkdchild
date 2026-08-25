package com.example.demo.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class VillageLandingController {

    @GetMapping("/landing")
    public String landing() {
        // After successful login Spring will redirect here automatically,
        // but we expose a simple landing page that forwards to complaint form.
        return "complaint-form";
    }
}

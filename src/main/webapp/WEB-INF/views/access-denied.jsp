<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Access Denied</title>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="${pageContext.request.contextPath}/resources/css/bootstrap-icons.css" rel="stylesheet"/>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/global.css">
</head>
<body>
    <a href="#main-content" class="skip-link">Skip to main content</a>
<div id="main-content" class="page-wrap">
    <header class="app-header">
        <div class="header-inner">
            <div class="header-left"></div>
            <div class="header-center">
                <div class="brand-center">
                    <div class="brand">Access Denied</div>
                    <div class="subtitle">Access Denied</div>
                </div>
            </div>
            <div class="header-right">
                <a href="${pageContext.request.contextPath}/login" class="btn btn-outline-light btn-sm">
                    <i class="bi bi-box-arrow-right"></i> Logout
                </a>
            </div>
        </div>
    </header>

    <div class="page-content container mt-4 mb-5">
        <div class="error-page">
            <i class="bi bi-exclamation-triangle-fill error-code"></i>
            <h1 class="error-title">Access Denied</h1>
            <p class="error-message">You do not have permission to view this resource. Please contact your administrator if you believe this is an error.</p>
            <div class="error-actions">
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-primary">
                    <i class="bi bi-speedometer2"></i> Go to Dashboard
                </a>
                <button onclick="history.back()" class="btn btn-secondary">
                    <i class="bi bi-arrow-left"></i> Go Back
                </button>
            </div>
        </div>
    </div>

    
</div>
    <script>
        function showToast(message, type) {
            type = type || 'info';
            const container = document.getElementById('toastContainer');
            if (!container) return;
            const iconMap = { success: 'bi-check-circle-fill', error: 'bi-exclamation-triangle-fill', warning: 'bi-exclamation-circle-fill', info: 'bi-info-circle-fill' };
            const toast = document.createElement('div');
            toast.className = 'toast ' + type;
            toast.innerHTML = '<i class="bi ' + iconMap[type] + '"></i><div class="toast-content">' + message + '</div><button class="toast-close" onclick="this.parentElement.remove()">&times;</button>';
            container.appendChild(toast);
            setTimeout(function() { toast.classList.add('hiding'); setTimeout(function() { if (toast.parentElement) toast.remove(); }, 300); }, 4000);
        }
    </script>
    <footer class="app-footer">
        Child Welfare Monitoring System<br>
        Government of Andhra Pradesh<br>
        Version 1.0 &copy; 2026
    </footer>
    <div class="toast-container" id="toastContainer"></div>
</body>
</html>
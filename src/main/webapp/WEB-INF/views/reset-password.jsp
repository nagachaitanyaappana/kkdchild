<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Reset Password - Child Protection System</title>
    <meta charset="UTF-8"/>
    <link href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css" rel="stylesheet"/>
    <style>
        body {
            background-color: #f8f9fa;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
        }
        .box {
            background-color: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            width: 400px;
        }
        .box h2 {
            margin-top: 0;
            text-align: center;
        }
        .btn-primary { width: 100%; }
    </style>
</head>
<body>
    <a href="#main-content" class="skip-link">Skip to main content</a>
<div class="box">
    <h2>Reset Password</h2>

    <c:if test="${param.resetSuccess != null}">
        <div class="page-alert page-alert-success show">
            <i class="bi bi-check-circle-fill"></i>
            <span>Your password has been reset. Please log in.</span>
        </div>
    </c:if>
    <c:if test="${error != null}">
        <div class="page-alert page-alert-error show">
            <i class="bi bi-exclamation-triangle-fill"></i>
            <span>${error}</span>
        </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/reset-password" method="post">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
        <div class="mb-3">
            <label for="token" class="form-label">Reset Token</label>
            <input type="text" class="form-control" id="token" name="token" value="${token}" required/>
        </div>
        <div class="mb-3">
            <label for="newPassword" class="form-label">New Password</label>
            <input type="password" class="form-control" id="newPassword" name="newPassword" required/>
        </div>
        <div class="mb-3">
            <label for="confirmPassword" class="form-label">Confirm New Password</label>
            <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required/>
        </div>
        <button type="submit" class="btn btn-primary">Reset</button>
    </form>

    <p style="font-size:0.9rem; text-align:center; color:#6c757d; margin-top:1rem;">
        <a href="${pageContext.request.contextPath}/login">Back to Login</a>
    </p>
</div>
    <script>
        function showToast(message, type) {
            type = type || 'info';
            const container = document.getElementById('toastContainer');
            if (!container) return;

            const iconMap = {
                success: 'bi-check-circle-fill',
                error: 'bi-exclamation-triangle-fill',
                warning: 'bi-exclamation-circle-fill',
                info: 'bi-info-circle-fill'
            };

            const toast = document.createElement('div');
            toast.className = 'toast ' + type;
            toast.innerHTML = '<i class="bi ' + iconMap[type] + '"></i>' +
                '<div class="toast-content">' + message + '</div>' +
                '<button class="toast-close" onclick="this.parentElement.remove()">&times;</button>';

            container.appendChild(toast);

            setTimeout(function() {
                toast.classList.add('hiding');
                setTimeout(function() {
                    if (toast.parentElement) {
                        toast.remove();
                    }
                }, 300);
            }, 4000);
        }

        function setLoading(buttonId, isLoading) {
            const btn = document.getElementById(buttonId);
            if (!btn) return;
            if (isLoading) {
                btn.classList.add('loading');
                btn.disabled = true;
            } else {
                btn.classList.remove('loading');
                btn.disabled = false;
            }
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
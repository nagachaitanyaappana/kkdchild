<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
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
                    <div class="brand">EGC Admin</div>
                    <div class="subtitle">User Management</div>
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
        <div class="row">
            <div class="col-md-8 offset-md-2">
                <div class="card form-card">
                    <div class="card-body">
                        <h2 class="section-title mb-4">User Management</h2>
                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Username</th>
                                        <th>Email</th>
                                        <th>Created At</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="user" items="${users}">
                                        <tr>
                                            <td><c:out value="${user.id}"/></td>
                                            <td><c:out value="${user.username}"/></td>
                                            <td><c:out value="${user.email}"/></td>
                                            <td><c:out value="${user.createdAt}"/></td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>

                        <hr class="my-4">

                        <h3 class="section-title mb-3">Add New User</h3>
                        <form action="${pageContext.request.contextPath}/users" method="post" id="addUserForm">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <div class="form-field">
                                        <label for="username" class="form-label">Username</label>
                                        <input type="text" class="form-control" id="username" name="username" required aria-required="true"/>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-field">
                                        <label for="email" class="form-label">Email</label>
                                        <input type="email" class="form-control" id="email" name="email" required aria-required="true"/>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-field">
                                        <label for="password" class="form-label">Password</label>
                                        <input type="password" class="form-control" id="password" name="password" required aria-required="true"/>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-field">
                                        <label for="villageName" class="form-label">Village Name</label>
                                        <input type="text" class="form-control" id="villageName" name="villageName" required aria-required="true"/>
                                    </div>
                                </div>
                                <div class="col-12">
                                    <button type="submit" class="btn btn-primary" id="addUserBtn">
                                        <i class="bi bi-person-plus"></i> Add User
                                    </button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
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
        function setLoading(buttonId, isLoading) {
            const btn = document.getElementById(buttonId);
            if (!btn) return;
            if (isLoading) { btn.classList.add('loading'); btn.disabled = true; }
            else { btn.classList.remove('loading'); btn.disabled = false; }
        }
        const addUserForm = document.getElementById('addUserForm');
        if (addUserForm) {
            addUserForm.addEventListener('submit', function() {
                setLoading('addUserBtn', true);
            });
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
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<!DOCTYPE html>
<html>
<head>
    <title>My Complaints</title>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="${pageContext.request.contextPath}/resources/css/bootstrap-icons.css" rel="stylesheet"/>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/global.css">
</head>
<body>
    <a href="#main-content" class="skip-link">Skip to main content</a>
<div class="page-wrap">
    <header class="app-header">
        <div class="header-inner">
            <div class="header-left"></div>
            <div class="header-center">
                <div class="brand-center">
                    <div class="brand"><c:out value="${villageName}"/> Dashboard</div>
                    <div class="subtitle">Child Welfare Monitoring System</div>
                </div>
                <ul class="nav-list">
                    <li><a href="${pageContext.request.contextPath}/complaint"><i class="bi bi-plus-circle"></i> Submit Complaint</a></li>
                    <li><a href="${pageContext.request.contextPath}/complaints/my" class="active"><i class="bi bi-list-ul"></i> My Complaints</a></li>
                </ul>
            </div>
            <div class="header-right">
                <form method="post" action="${pageContext.request.contextPath}/api/auth/logout" style="display:inline;">
                    <button type="submit" class="btn btn-outline-light btn-sm">
                        <i class="bi bi-box-arrow-right"></i> Logout
                    </button>
                </form>
            </div>
        </div>
    </header>

    <div id="main-content" class="page-content container mt-4 mb-5">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h2 class="section-title"><i class="bi bi-file-earmark-text"></i> My Complaints</h2>
        </div>

        <div class="card form-card mb-4">
            <div class="card-body">
                <form method="get" action="${pageContext.request.contextPath}/complaints/my" class="row g-3">
                    <div class="col-md-4">
                        <label for="type" class="form-label">Complaint Type</label>
                        <select class="form-select" id="type" name="type">
                            <option value="">All Types</option>
                            <option value="CHILD_MARRIAGE" ${selectedType == 'CHILD_MARRIAGE' ? 'selected' : ''}>Child Marriage</option>
                            <option value="POCSO" ${selectedType == 'POCSO' ? 'selected' : ''}>POCSO</option>
                            <option value="CHILD_LABOUR" ${selectedType == 'CHILD_LABOUR' ? 'selected' : ''}>Child Labour</option>
                            <option value="SCHOOL_DROPOUTS" ${selectedType == 'SCHOOL_DROPOUTS' ? 'selected' : ''}>School Dropouts</option>
                            <option value="CHILD_NEGLIGENCY" ${selectedType == 'CHILD_NEGLIGENCY' ? 'selected' : ''}>Children Negligency</option>
                            <option value="HIV_INFECTION" ${selectedType == 'HIV_INFECTION' ? 'selected' : ''}>HIV Infection</option>
                            <option value="ORPHANS" ${selectedType == 'ORPHANS' ? 'selected' : ''}>Orphans</option>
                            <option value="OTHER" ${selectedType == 'OTHER' ? 'selected' : ''}>Other</option>
                        </select>
                    </div>
                    <div class="col-md-4 d-flex align-items-end">
                        <button type="submit" class="btn btn-primary me-2">
                            <i class="bi bi-funnel"></i> Filter
                        </button>
                        <a href="${pageContext.request.contextPath}/complaints/my" class="btn btn-secondary">
                            <i class="bi bi-arrow-counterclockwise"></i> Reset
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <div class="card form-card">
            <div class="card-body">
                <c:choose>
                    <c:when test="${empty complaints}">
                        <div class="empty-state">
                                <span class="empty-state-icon"><i class="bi bi-inbox"></i></span>
                                <div class="empty-state-title">No complaints found</div>
                                <div class="empty-state-text">You have not submitted any complaints yet.</div>
                            </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Type</th>
                                        <th>Description</th>
                                        <th>Submitted Date</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="complaint" items="${complaints}">
                                        <tr>
                                            <td>${complaint.id}</td>
                                            <td><c:out value="${complaint.type}"/></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${fn:length(complaint.content) > 100}">
                                                        <c:out value="${fn:substring(complaint.content, 0, 100)}"/>...
                                                    </c:when>
                                                    <c:otherwise>
                                                        <c:out value="${complaint.content}"/>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td><c:out value="${complaint.createdAt}"/></td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/complaints/${complaint.id}" class="btn btn-sm btn-primary">
                                                    <i class="bi bi-eye"></i> View Details
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <footer class="app-footer" style="background:var(--accent); color:rgba(255,255,255,0.85); padding:1.2rem 0; text-align:center; font-size:0.85rem;">
    </footer>
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
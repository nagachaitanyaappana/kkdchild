<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Reports - ${mandal.name}</title>
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
                    <div class="brand">Admin Dashboard</div>
                    <div class="subtitle">Reports - <c:out value="${mandal.name}"/></div>
                </div>
                <ul class="nav-list">
                    <li><a href="${pageContext.request.contextPath}/admin/dashboard"><i class="bi bi-speedometer2"></i> Dashboard</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/reports" class="active"><i class="bi bi-bar-chart"></i> Reports</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/complaints"><i class="bi bi-file-earmark-text"></i> Complaints</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/localities"><i class="bi bi-geo-alt"></i> Localities</a></li>
                </ul>
            </div>
            <div class="header-right">
                <a href="${pageContext.request.contextPath}/login" class="btn btn-outline-light btn-sm">
                    <i class="bi bi-box-arrow-right"></i> Logout
                </a>
            </div>
        </div>
    </header>

    <div id="main-content" class="page-content container mt-4 mb-5">

        <div class="d-flex justify-content-between align-items-end mb-4">
            <div>
                <h1 class="section-title">Mandal Reports</h1>
                <p class="text-muted mb-0">
                    <i class="bi bi-geo-alt"></i> <c:out value="${mandal.district}"/>
                    <span class="ms-2" style="background:var(--primary); color:#fff; font-size:0.8rem; padding:0.35rem 0.6rem; border-radius:0.25rem; font-weight:500;">Total Villages: ${totalVillages}</span>
                </p>
            </div>
            <a href="${pageContext.request.contextPath}/admin/mandal/${mandal.id}" class="btn btn-secondary btn-sm">&larr; Back to Villages</a>
        </div>

        <div class="row g-4 mb-4" style="display:flex; flex-wrap:wrap;">
            <div class="col-6">
                <div class="stat-card" style="border-top: 4px solid #2563eb;">
                    <div class="stat-icon" style="color:#2563eb;"><i class="bi bi-file-earmark-text"></i></div>
                    <div class="stat-value">${totalComplaints}</div>
                    <div class="stat-label">Total Complaints</div>
                </div>
            </div>
            <div class="col-6">
                <div class="stat-card" style="border-top: 4px solid #dc2626;">
                    <div class="stat-icon" style="color:#dc2626;"><i class="bi bi-exclamation-circle-fill"></i></div>
                    <div class="stat-value">${pendingComplaints}</div>
                    <div class="stat-label">Pending Complaints</div>
                </div>
            </div>
        </div>

        <div id="submittedTable" class="detail-table">
            <div class="card form-card mb-3">
                <div class="card-body">
                    <h5 class="section-title"><i class="bi bi-check-circle-fill" style="color:#2563eb;"></i> Submitted Villages</h5>
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Village Name</th>
                                    <th>Last Submission</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="village" items="${submitted}" varStatus="loop">
                                    <tr>
                                        <td>${loop.index + 1}</td>
                                        <td><c:out value="${village.name}"/></td>
                                        <td>
                                            <c:set var="complaints" value="${complainMap[village.id]}"/>
                                            <c:choose>
                                                <c:when test="${not empty complaints}">
                                                    <c:out value="${complaints[0].createdAt}"/>
                                                </c:when>
                                                <c:otherwise>N/A</c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty submitted}">
                                    <tr>
                                        <td colspan="3" class="text-center">No villages have submitted yet.</td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <div id="pendingTable" class="detail-table">
            <div class="card form-card mb-3">
                <div class="card-body">
                    <h5 class="section-title"><i class="bi bi-exclamation-circle-fill" style="color:#dc2626;"></i> Pending Villages</h5>
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Village Name</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="village" items="${notSubmitted}" varStatus="loop">
                                    <tr>
                                        <td>${loop.index + 1}</td>
                                        <td><c:out value="${village.name}"/></td>
                                        <td>
                                            <span class="locality-badge locality-no-reports">No Reports</span>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty notSubmitted}">
                                    <tr>
                                        <td colspan="3" class="text-center">All villages have submitted.</td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <footer class="app-footer" style="background:var(--accent); color:rgba(255,255,255,0.85); padding:1.2rem 0; text-align:center; font-size:0.85rem;">
    </footer>
</div>

    <script>
<script>
    function toggleTable(tableId) {
        const table = document.getElementById(tableId);
        table.classList.toggle('active');
    }
</script>
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
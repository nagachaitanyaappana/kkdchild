<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title><c:out value="${pageTitle}"/></title>
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
                    <div class="subtitle"><c:out value="${pageTitle}"/></div>
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
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h2 class="section-title"><c:out value="${pageTitle}"/></h2>
            <div>
                <a href="${pageContext.request.contextPath}/admin/reports/export/details/excel?type=${reportType}&division=${selectedDivisionId != null ? selectedDivisionId : ''}&locality=${selectedVillageId != null ? selectedVillageId : ''}&complaintType=${selectedType != null ? selectedType : ''}&priority=${selectedPriority != null ? selectedPriority : ''}&dateFrom=${dateFrom != null ? dateFrom : ''}&dateTo=${dateTo != null ? dateTo : ''}" class="btn btn-success btn-sm me-2">
                    <i class="bi bi-file-earmark-excel"></i> Export Excel
                </a>
                <a href="${pageContext.request.contextPath}/admin/reports/export/details/pdf?type=${reportType}&division=${selectedDivisionId != null ? selectedDivisionId : ''}&locality=${selectedVillageId != null ? selectedVillageId : ''}&complaintType=${selectedType != null ? selectedType : ''}&priority=${selectedPriority != null ? selectedPriority : ''}&dateFrom=${dateFrom != null ? dateFrom : ''}&dateTo=${dateTo != null ? dateTo : ''}" class="btn btn-danger btn-sm me-2">
                    <i class="bi bi-file-earmark-pdf"></i> Export PDF
                </a>
                <a href="${pageContext.request.contextPath}/admin/reports" class="btn btn-secondary btn-sm">
                    <i class="bi bi-arrow-left"></i> Back
                </a>
            </div>
        </div>

        <div class="card form-card">
            <div class="card-body">
                <c:choose>
                    <c:when test="${not empty complaints}">
                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Complaint ID</th>
                                        <th>Complaint Type</th>
                                        <th>Locality Name</th>
                                        <th>Mandal Name</th>
                                        <th>Submitted By</th>
                                        <th>Priority</th>
                                        <th>Created Date</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="complaint" items="${complaints}">
                                        <tr>
                                            <td>${complaint.id}</td>
                                            <td><c:out value="${complaint.type}"/></td>
                                            <td>
                                                <c:out value="${complaint.user.village.name}"/>
                                            </td>
                                            <td>
                                                <c:out value="${complaint.user.village.mandal != null ? complaint.user.village.mandal.name : 'N/A'}"/>
                                            </td>
                                            <td><c:out value="${complaint.user.username}"/></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${complaint.priority == 'LOW'}">
                                                        <span class="priority-badge priority-low">Low</span>
                                                    </c:when>
                                                    <c:when test="${complaint.priority == 'MEDIUM'}">
                                                        <span class="priority-badge priority-medium">Medium</span>
                                                    </c:when>
                                                    <c:when test="${complaint.priority == 'HIGH'}">
                                                        <span class="priority-badge priority-high">High</span>
                                                    </c:when>
                                                    <c:when test="${complaint.priority == 'CRITICAL'}">
                                                        <span class="priority-badge priority-critical">Critical</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="priority-badge priority-medium">Medium</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td><c:out value="${complaint.createdAt}"/></td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>

                    <c:when test="${not empty pendingVillages}">
                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Locality Name</th>
                                        <th>Division Name</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="village" items="${pendingVillages}">
                                        <tr>
                                            <td><c:out value="${village.name}"/></td>
                                            <td>
                                                <c:out value="${village.mandal != null ? village.mandal.name : 'N/A'}"/>
                                            </td>
                                            <td>
                                                <span class="locality-badge locality-no-reports">No Reports</span>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>

                    <c:when test="${not empty pendingLocalities}">
                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Locality Name</th>
                                        <th>Division Name</th>
                                        <th>Last Report Date</th>
                                        <th>Days Since Last Report</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="row" items="${pendingLocalities}">
                                        <c:set var="village" value="${row.village}"/>
                                        <c:set var="status" value="${row.status}"/>
                                        <tr>
                                            <td><c:out value="${village.name}"/></td>
                                            <td>
                                                <c:out value="${row.divisionName != null ? row.divisionName : 'N/A'}"/>
                                            </td>
                                            <td>
                                                <c:out value="${row.lastReportDate != null ? row.lastReportDate : 'N/A'}"/>
                                            </td>
                                            <td>
                                                <c:out value="${row.daysSince != null ? row.daysSince : 'N/A'}"/>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${status == 'Active'}">
                                                        <span class="locality-badge locality-active">Active</span>
                                                    </c:when>
                                                    <c:when test="${status == 'Pending'}">
                                                        <span class="locality-badge locality-pending">Pending</span>
                                                    </c:when>
                                                    <c:when test="${status == 'Inactive'}">
                                                        <span class="locality-badge locality-pending">Inactive</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="locality-badge locality-no-reports">No Reports</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <div class="empty-state">
                                <span class="empty-state-icon"><i class="bi bi-bar-chart"></i></span>
                                <div class="empty-state-title">No data available</div>
                                <div class="empty-state-text">There is no data available for this report type.</div>
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
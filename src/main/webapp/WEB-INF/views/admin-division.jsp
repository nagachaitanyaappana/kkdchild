<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title><c:out value="${division.name}"/></title>
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
                    <div class="subtitle"><c:out value="${division.name}"/></div>
                </div>
                <ul class="nav-list">
                    <li><a href="${pageContext.request.contextPath}/admin/dashboard"><i class="bi bi-speedometer2"></i> Dashboard</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/reports"><i class="bi bi-bar-chart"></i> Reports</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/complaints"><i class="bi bi-file-earmark-text"></i> Complaints</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/localities" class="active"><i class="bi bi-geo-alt"></i> Localities</a></li>
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
        <nav aria-label="breadcrumb" class="mb-3">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard"><i class="bi bi-speedometer2"></i> Dashboard</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/localities"><i class="bi bi-geo-alt"></i> Localities</a></li>
                <li class="breadcrumb-item active" aria-current="page"><c:out value="${division.name}"/></li>
            </ol>
        </nav>

        <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
                <h1 class="section-title"><c:out value="${division.name}"/></h1>
                <p class="text-muted mb-0">
                    <span class="badge bg-secondary">${division.type}</span>
                    <span class="ms-2 text-muted">Division</span>
                </p>
            </div>
            <div>
                <a href="${pageContext.request.contextPath}/admin/division/${division.id}/export/excel" class="btn btn-success btn-sm me-2">
                    <i class="bi bi-file-earmark-excel"></i> Export Excel
                </a>
                <a href="${pageContext.request.contextPath}/admin/division/${division.id}/export/pdf" class="btn btn-danger btn-sm me-2">
                    <i class="bi bi-file-earmark-pdf"></i> Export PDF
                </a>
                <a href="${pageContext.request.contextPath}/admin/localities" class="btn btn-secondary btn-sm">&larr; Back</a>
            </div>
        </div>

        <div class="row g-4 mb-4" style="display:flex; flex-wrap:wrap;">
            <div class="col-6">
                <div class="stat-card" style="background:#2563eb; color:#fff; border-top:none;">
                    <div class="stat-icon" style="color:#fff;"><i class="bi bi-geo-alt"></i></div>
                    <div class="stat-value" style="color:#fff;">${totalLocalities}</div>
                    <div class="stat-label" style="color:#fff;">
                        <c:choose>
                            <c:when test="${division.type == 'MANDAL'}">Total Villages</c:when>
                            <c:when test="${division.type == 'MUNICIPALITY' || division.type == 'CORPORATION' || division.type == 'NAGAR_PANCHAYAT'}">Total Wards</c:when>
                            <c:otherwise>Total Localities</c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
            <div class="col-6">
                <div class="stat-card" style="background:#f97316; color:#fff; border-top:none;">
                    <div class="stat-icon" style="color:#fff;"><i class="bi bi-file-earmark-text"></i></div>
                    <div class="stat-value" style="color:#fff;">${totalComplaints}</div>
                    <div class="stat-label" style="color:#fff;">Total Complaints</div>
                </div>
            </div>
        </div>

        <div class="row g-4 mb-4" style="display:flex; flex-wrap:wrap;">
            <div class="col-6">
                <div class="stat-card" style="background:#dc2626; color:#fff; border-top:none;">
                    <div class="stat-icon" style="color:#fff;"><i class="bi bi-exclamation-circle-fill"></i></div>
                    <div class="stat-value" style="color:#fff;">${pendingComplaints}</div>
                    <div class="stat-label" style="color:#fff;">Pending Complaints</div>
                </div>
            </div>
        </div>

        <div class="row mb-3">
            <div class="col-12">
                <h3 class="section-title">
                    <c:choose>
                        <c:when test="${division.type == 'MANDAL'}">Villages</c:when>
                        <c:when test="${division.type == 'MUNICIPALITY' || division.type == 'CORPORATION' || division.type == 'NAGAR_PANCHAYAT'}">Wards</c:when>
                        <c:otherwise>Localities</c:otherwise>
                    </c:choose>
                </h3>
                <c:choose>
                    <c:when test="${empty localities}">
                        <div class="empty-state">
                                <span class="empty-state-icon"><i class="bi bi-geo-alt"></i></span>
                                <div class="empty-state-title">No localities found</div>
                                <div class="empty-state-text">This division does not have any localities registered yet.</div>
                            </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>#</th>
                                        <th>Locality Name</th>
                                        <th>Status</th>
                                        <th>Last Report</th>
                                        <th>Complaints</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="locality" items="${localities}" varStatus="loop">
                                        <c:set var="lastSubmission" value="${lastSubmissionMap[locality.id]}"/>
                                        <c:set var="status" value="${statusMap[locality.id]}"/>
                                        <c:set var="locComplaints" value="${complaintCountMap[locality.id]}"/>
                                        <c:set var="lastReport" value="${lastReportMap[locality.id]}"/>
                                        <tr>
                                            <td>${loop.index + 1}</td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/admin/village/${locality.id}" class="text-decoration-none">
                                                    <c:out value="${locality.name}"/>
                                                </a>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${status == 'Active'}">
                                                        <span class="locality-badge locality-active">Active</span>
                                                    </c:when>
                                                    <c:when test="${status == 'Pending'}">
                                                        <span class="locality-badge locality-pending">Pending</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="locality-badge locality-no-reports">No Reports</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>${lastReport}</td>
                                            <td>${locComplaints}</td>
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
     

    <footer class="app-footer">
        Child Welfare Monitoring System<br>
        Government of Andhra Pradesh<br>
        Version 1.0 &copy; 2026
    </footer>
    <div class="toast-container" id="toastContainer"></div>
</body>
</html>
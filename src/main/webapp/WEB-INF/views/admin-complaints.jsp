<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Complaints</title>
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
                    <div class="subtitle">Complaints</div>
                </div>
                <ul class="nav-list">
                    <li><a href="${pageContext.request.contextPath}/admin/dashboard"><i class="bi bi-speedometer2"></i> Dashboard</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/reports"><i class="bi bi-bar-chart"></i> Reports</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/complaints" class="active"><i class="bi bi-file-earmark-text"></i> Complaints</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/localities"><i class="bi bi-geo-alt"></i> Localities</a></li>
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
            <h2 class="section-title"><i class="bi bi-file-earmark-text"></i> All Complaints</h2>
        </div>

        <div class="card form-card mb-4">
            <div class="card-body">
                <form method="get" action="${pageContext.request.contextPath}/admin/complaints" class="row g-3">
                    <div class="col-md-3">
                        <label for="search" class="form-label">Search</label>
                        <input type="text" class="form-control" id="search" name="search" value="${search != null ? search : ''}" placeholder="ID, type, locality..."/>
                    </div>
                    <div class="col-md-3">
                        <label for="type" class="form-label">Complaint Type</label>
                        <select class="form-select" id="type" name="type">
                            <option value="">All Types</option>
                            <c:forEach var="t" items="${complaintTypes}">
                                <option value="${t}" ${selectedType == t ? 'selected' : ''}>${t}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label for="villageId" class="form-label">Locality</label>
                        <select class="form-select" id="villageId" name="villageId">
                            <option value="">All Localities</option>
                            <c:forEach var="village" items="${villages}">
                                <option value="${village.id}" ${selectedVillageId == village.id ? 'selected' : ''}>${village.name}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="col-12">
                        <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-toggle="collapse" data-bs-target="#advancedFilters" aria-expanded="true">
                            <i class="bi bi-funnel"></i> Advanced Filters
                        </button>
                    </div>

                    <div class="col-12 collapse show" id="advancedFilters">
                        <div class="card bg-light mt-3">
                            <div class="card-body">
                                <div class="row g-3">
                                    <div class="col-md-3">
                                        <label for="complaintId" class="form-label">Complaint ID</label>
                                        <input type="text" class="form-control" id="complaintId" name="complaintId" value="${complaintId != null ? complaintId : ''}" placeholder="e.g. 123"/>
                                    </div>
                                    <div class="col-md-3">
                                        <label for="submittedBy" class="form-label">Submitted By</label>
                                        <input type="text" class="form-control" id="submittedBy" name="submittedBy" value="${submittedBy != null ? submittedBy : ''}" placeholder="Username"/>
                                    </div>
                                    <div class="col-md-3">
                                        <label for="dateFrom" class="form-label">Date From</label>
                                        <input type="date" class="form-control" id="dateFrom" name="dateFrom" value="${dateFrom != null ? dateFrom : ''}"/>
                                    </div>
                                    <div class="col-md-3">
                                        <label for="dateTo" class="form-label">Date To</label>
                                        <input type="date" class="form-control" id="dateTo" name="dateTo" value="${dateTo != null ? dateTo : ''}"/>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-12 d-flex justify-content-between">
                        <div>
                            <c:if test="${not empty activeFilters}">
                                <a href="${pageContext.request.contextPath}/admin/complaints" class="btn btn-outline-danger btn-sm">
                                    <i class="bi bi-x-circle"></i> Clear Filters
                                </a>
                            </c:if>
                        </div>
                        <div>
                            <button type="submit" class="btn btn-primary me-2" id="searchComplaintsBtn" onclick="setLoading('searchComplaintsBtn', true)">
                                <i class="bi bi-search"></i> Apply Filters
                            </button>
                            <a href="${pageContext.request.contextPath}/admin/complaints" class="btn btn-secondary">
                                <i class="bi bi-arrow-counterclockwise"></i> Reset
                            </a>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <c:if test="${not empty activeFilters}">
            <div class="alert alert-info py-2">
                <strong>Showing:</strong> ${complaints.size()} Complaints
                <c:forEach var="filter" items="${activeFilters}">
                    <span class="badge bg-primary ms-2">${filter}</span>
                </c:forEach>
            </div>
        </c:if>
        <c:if test="${empty activeFilters}">
            <div class="alert alert-info py-2">
                <strong>Showing:</strong> ${complaints.size()} Complaints
            </div>
        </c:if>

        <div class="card form-card">
            <div class="card-body">
                <c:choose>
                    <c:when test="${empty complaints}">
                        <div class="text-center py-5">
                            <i class="bi bi-inbox" style="font-size:3rem; color:#ccc;"></i>
                            <h4 class="mt-3 text-muted">No matching complaints found.</h4>
                            <p class="text-muted">Try changing your filters.</p>
                            <a href="${pageContext.request.contextPath}/admin/complaints" class="btn btn-primary">
                                <i class="bi bi-arrow-counterclockwise"></i> Clear Filters
                            </a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Type</th>
                                        <th>Locality</th>
                                        <th>Submitted By</th>
                                        <th>Created Date</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="complaint" items="${complaints}">
                                        <tr>
                                            <td>${complaint.id}</td>
                                            <td><c:out value="${complaint.type}"/></td>
                                            <td><c:out value="${complaint.user.village.name}"/></td>
                                            <td><c:out value="${complaint.user.username}"/></td>
                                            <td><c:out value="${complaint.createdAt}"/></td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/admin/complaints/${complaint.id}" class="btn btn-sm btn-primary">
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
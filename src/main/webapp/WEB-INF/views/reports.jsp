<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Overall Reports</title>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="${pageContext.request.contextPath}/resources/css/bootstrap-icons.css" rel="stylesheet"/>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/global.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
                    <div class="subtitle">Overall Reports</div>
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

        <h1 class="section-title mb-4">Overall Reports</h1>

        <div class="card form-card mb-4">
            <div class="card-body">
                <form method="get" action="${pageContext.request.contextPath}/admin/reports" class="row g-3">
                    <div class="col-md-3">
                        <label for="division" class="form-label">Division</label>
                        <select class="form-select" id="division" name="division">
                            <option value="">All Divisions</option>
                            <c:forEach var="d" items="${allDivisions}">
                                <option value="${d.id}" ${selectedDivisionId == d.id ? 'selected' : ''}>${d.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label for="locality" class="form-label">Locality</label>
                        <select class="form-select" id="locality" name="locality">
                            <option value="">All Localities</option>
                            <c:forEach var="village" items="${allVillages}">
                                <option value="${village.id}" ${selectedVillageId == village.id ? 'selected' : ''}>${village.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label for="type" class="form-label">Complaint Type</label>
                        <select class="form-select" id="type" name="type">
                            <option value="">All Types</option>
                            <c:forEach var="t" items="${complaintTypes}">
                                <option value="${t}" ${selectedType == t ? 'selected' : ''}>${t}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label for="dateFrom" class="form-label">Date From</label>
                        <input type="date" class="form-control" id="dateFrom" name="dateFrom" value="${dateFrom != null ? dateFrom : ''}"/>
                    </div>
                    <div class="col-md-2">
                        <label for="dateTo" class="form-label">Date To</label>
                        <input type="date" class="form-control" id="dateTo" name="dateTo" value="${dateTo != null ? dateTo : ''}"/>
                    </div>
                    <div class="col-md-2 d-flex align-items-end">
                        <button type="submit" class="btn btn-primary me-2">
                            <i class="bi bi-search"></i> Apply Filters
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/reports" class="btn btn-secondary">
                            <i class="bi bi-arrow-counterclockwise"></i> Reset
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <div class="row g-4 mb-4" style="display:flex; flex-wrap:wrap;">
            <div class="col-6">
                <a href="${pageContext.request.contextPath}/admin/reports/details?type=TOTAL" class="text-decoration-none d-block">
                    <div class="stat-card" style="background:#2563eb; color:#fff; border-top:none;">
                        <div class="stat-icon" style="color:#fff;"><i class="bi bi-file-earmark-text"></i></div>
                        <div class="stat-value" style="color:#fff;">${totalComplaints}</div>
                        <div class="stat-label" style="color:#fff;">Total Complaints</div>
                    </div>
                </a>
            </div>
            <div class="col-6">
                <a href="${pageContext.request.contextPath}/admin/reports/details?type=PENDING" class="text-decoration-none d-block">
                    <div class="stat-card" style="background:#f97316; color:#fff; border-top:none;">
                        <div class="stat-icon" style="color:#fff;"><i class="bi bi-exclamation-circle-fill"></i></div>
                        <div class="stat-value" style="color:#fff;">${pendingComplaints}</div>
                        <div class="stat-label" style="color:#fff;">Pending Complaints</div>
                    </div>
                </a>
            </div>
        </div>

        <div class="row g-4 mb-4" style="display:flex; flex-wrap:wrap;">

        </div>

        <div class="row g-4 mb-4" style="display:flex; flex-wrap:wrap;">


        <h2 class="section-title mb-4">District Analytics</h2>

        <div class="row g-4 mb-4" style="display:flex; flex-wrap:wrap;">
            <div class="col-md-6">
                <div class="card form-card h-100">
                    <div class="card-body">
                        <h5 class="section-title">Complaint Distribution by Type</h5>
                        <canvas id="typeChart"></canvas>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card form-card h-100">
                    <div class="card-body">
                        <h5 class="section-title">Complaints by Priority</h5>
                        <canvas id="priorityChart"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4 mb-4" style="display:flex; flex-wrap:wrap;">
            <div class="col-md-6">
                <div class="card form-card h-100">
                    <div class="card-body">
                        <h5 class="section-title">Complaints by Administrative Division</h5>
                        <canvas id="divisionChart"></canvas>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card form-card h-100">
                    <div class="card-body">
                        <h5 class="section-title">Monthly Complaint Trend</h5>
                        <canvas id="trendChart"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4 mb-4" style="display:flex; flex-wrap:wrap;">
            <div class="col-md-6">
                <div class="card form-card h-100">
                    <div class="card-body">
                        <h5 class="section-title">Locality Activity</h5>
                        <canvas id="activityChart"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4 mb-4" style="display:flex; flex-wrap:wrap;">
            <div class="col-md-6">
                <div class="card form-card mb-3">
                    <div class="card-body">
                        <h5 class="section-title"><i class="bi bi-trophy"></i> Top 5 Divisions</h5>
                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Division</th>
                                        <th>Total Complaints</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="division" items="${topDivisions}" varStatus="loop">
                                        <tr>
                                            <td>${loop.index + 1}. <c:out value="${division.name}"/></td>
                                            <td><c:out value="${division.count}"/></td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty topDivisions}">
                                        <tr>
                                            <td colspan="2" class="text-center">No data available.</td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

        </div>

        <div class="row mb-3">
            <div class="col-12">
                <h3 class="section-title"><i class="bi bi-exclamation-triangle-fill" style="color:#7f1d1d;"></i> Recent Critical Complaints</h3>
                <c:choose>
                    <c:when test="${empty recentCritical}">
                        <div class="empty-state">
                                <span class="empty-state-icon"><i class="bi bi-shield-check"></i></span>
                                <div class="empty-state-title">No critical complaints</div>
                                <div class="empty-state-text">Great! There are no critical complaints at this time.</div>
                            </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Complaint ID</th>
                                        <th>Complaint Type</th>
                                        <th>Division</th>
                                        <th>Locality</th>
                                        <th>Submitted By</th>
                                        <th>Submitted Date</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="complaint" items="${recentCritical}">
                                        <tr>
                                            <td>${complaint.id}</td>
                                            <td><c:out value="${complaint.type}"/></td>
                                            <td>
                                                <c:out value="${complaint.user.village.mandal != null ? complaint.user.village.mandal.name : 'N/A'}"/>
                                            </td>
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

        <div class="card form-card mb-3">
            <div class="card-body">
                <h5 class="section-title"><i class="bi bi-bar-chart"></i> Complaints by Type</h5>
                <div class="table-responsive">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Type</th>
                                <th>Count</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="entry" items="${complaintsByType}">
                                <tr>
                                    <td><c:out value="${entry.key}"/></td>
                                    <td><c:out value="${entry.value}"/></td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty complaintsByType}">
                                <tr>
                                    <td colspan="2" class="text-center">No complaints yet.</td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <footer class="app-footer" style="background:var(--accent); color:rgba(255,255,255,0.85); padding:1.2rem 0; text-align:center; font-size:0.85rem;">
    </footer>
</div>

    <script>
    const chartColors = {
        blue: '#2563eb',
        green: '#22c55e',
        orange: '#f97316',
        red: '#dc2626',
        purple: '#7c3aed',
        yellow: '#eab308'
    };

    const typeLabels = [];
    const typeData = [];
    <c:forEach var="entry" items="${complaintsByType}">
        typeLabels.push('<c:out value="${entry.key}"/>');
        typeData.push(${entry.value});
    </c:forEach>
    new Chart(document.getElementById('typeChart'), {
        type: 'pie',
        data: {
            labels: typeLabels,
            datasets: [{
                data: typeData,
                backgroundColor: [
                    chartColors.blue, chartColors.green, chartColors.orange,
                    chartColors.red, chartColors.purple, chartColors.yellow,
                    '#1e40af', '#15803d'
                ]
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: { position: 'bottom' }
            }
        }
    });

    const divisionLabels = [];
    const divisionData = [];
    <c:forEach var="entry" items="${complaintsByDivision}">
        divisionLabels.push('<c:out value="${entry.key}"/>');
        divisionData.push(${entry.value});
    </c:forEach>
    new Chart(document.getElementById('divisionChart'), {
        type: 'bar',
        data: {
            labels: divisionLabels,
            datasets: [{
                label: 'Complaints',
                data: divisionData,
                backgroundColor: chartColors.blue
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            scales: {
                y: { beginAtZero: true, ticks: { stepSize: 1 } }
            },
            plugins: {
                legend: { display: false }
            }
        }
    });

    const trendLabels = [];
    const trendData = [];
    <c:forEach var="entry" items="${monthlyTrend}">
        trendLabels.push('<c:out value="${entry.key}"/>');
        trendData.push(${entry.value});
    </c:forEach>
    new Chart(document.getElementById('trendChart'), {
        type: 'line',
        data: {
            labels: trendLabels,
            datasets: [{
                label: 'Complaints',
                data: trendData,
                borderColor: chartColors.green,
                backgroundColor: chartColors.green + '20',
                fill: true,
                tension: 0.3
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            scales: {
                y: { beginAtZero: true, ticks: { stepSize: 1 } }
            },
            plugins: {
                legend: { display: false }
            }
        }
    });

    const activityLabels = [];
    const activityData = [];
    <c:forEach var="entry" items="${localityActivityMap}">
        activityLabels.push('<c:out value="${entry.key}"/>');
        activityData.push(${entry.value});
    </c:forEach>
    new Chart(document.getElementById('activityChart'), {
        type: 'doughnut',
        data: {
            labels: activityLabels,
            datasets: [{
                data: activityData,
                backgroundColor: [
                    chartColors.green,
                    chartColors.red
                ]
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: { position: 'bottom' }
            }
        }
    });
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
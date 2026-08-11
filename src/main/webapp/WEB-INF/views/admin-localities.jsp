<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Administrative Divisions</title>
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
                    <div class="subtitle">Administrative Divisions</div>
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
        <div class="text-center mb-4">
            <h1 class="section-title">Administrative Divisions</h1>
            <p class="text-muted mb-0">Select a category to view its divisions.</p>
        </div>

        <c:choose>
            <c:when test="${empty selectedType}">
                <div class="row g-4 mb-4" style="display:flex; flex-wrap:wrap;">
                    <div class="col-6 col-md-3">
                        <a href="${pageContext.request.contextPath}/admin/localities?type=MANDAL" class="text-decoration-none d-block">
                            <div class="stat-card" style="background:#2563eb; color:#fff; border-top:none;">
                                <div class="stat-icon" style="color:#fff;"><i class="bi bi-map"></i></div>
                                <div class="stat-value" style="color:#fff;">${mandalCount}</div>
                                <div class="stat-label" style="color:#fff;">Mandals</div>
                                <div class="small text-white-50">View Mandals &rarr;</div>
                            </div>
                        </a>
                    </div>
                    <div class="col-6 col-md-3">
                        <a href="${pageContext.request.contextPath}/admin/localities?type=MUNICIPALITY" class="text-decoration-none d-block">
                            <div class="stat-card" style="background:#f97316; color:#fff; border-top:none;">
                                <div class="stat-icon" style="color:#fff;"><i class="bi bi-building"></i></div>
                                <div class="stat-value" style="color:#fff;">${municipalityCount}</div>
                                <div class="stat-label" style="color:#fff;">Municipalities</div>
                                <div class="small text-white-50">View Municipalities &rarr;</div>
                            </div>
                        </a>
                    </div>
                    <div class="col-6 col-md-3">
                        <a href="${pageContext.request.contextPath}/admin/localities?type=CORPORATION" class="text-decoration-none d-block">
                            <div class="stat-card" style="background:#dc2626; color:#fff; border-top:none;">
                                <div class="stat-icon" style="color:#fff;"><i class="bi bi-building-fill"></i></div>
                                <div class="stat-value" style="color:#fff;">${corporationCount}</div>
                                <div class="stat-label" style="color:#fff;">Municipal Corporation</div>
                                <div class="small text-white-50">View Corporation &rarr;</div>
                            </div>
                        </a>
                    </div>
                    <div class="col-6 col-md-3">
                        <a href="${pageContext.request.contextPath}/admin/localities?type=NAGAR_PANCHAYAT" class="text-decoration-none d-block">
                            <div class="stat-card" style="background:#7c3aed; color:#fff; border-top:none;">
                                <div class="stat-icon" style="color:#fff;"><i class="bi bi-house-fill"></i></div>
                                <div class="stat-value" style="color:#fff;">${nagarPanchayatCount}</div>
                                <div class="stat-label" style="color:#fff;">Nagar Panchayats</div>
                                <div class="small text-white-50">View Nagar Panchayats &rarr;</div>
                            </div>
                        </a>
                    </div>
                </div>
            </c:when>

            <c:otherwise>
                <c:set var="typeLabel" value="${selectedType}"/>
                <c:choose>
                    <c:when test="${selectedType == 'MANDAL'}"><c:set var="typeLabel" value="Mandals"/></c:when>
                    <c:when test="${selectedType == 'MUNICIPALITY'}"><c:set var="typeLabel" value="Municipalities"/></c:when>
                    <c:when test="${selectedType == 'CORPORATION'}"><c:set var="typeLabel" value="Municipal Corporation"/></c:when>
                    <c:when test="${selectedType == 'NAGAR_PANCHAYAT'}"><c:set var="typeLabel" value="Nagar Panchayats"/></c:when>
                </c:choose>

                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h2 class="section-title"><c:out value="${typeLabel}"/></h2>
                    <a href="${pageContext.request.contextPath}/admin/localities" class="btn btn-secondary btn-sm">
                        <i class="bi bi-arrow-left"></i> All Categories
                    </a>
                </div>

                <c:set var="divisions" value="${filteredDivisions}"/>
                <c:if test="${empty divisions}">
                    <div class="text-center py-5">
                        <i class="bi bi-search" style="font-size:3rem; color:#ccc;"></i>
                        <h4 class="mt-3 text-muted">No divisions found.</h4>
                    </div>
                </c:if>
                <c:if test="${not empty divisions}">
                    <div class="row g-3 mb-4" style="display:flex; flex-wrap:wrap;">
                        <c:forEach var="division" items="${divisions}" varStatus="loop">
                            <div class="col-md-4 col-sm-6">
                                <a href="${pageContext.request.contextPath}/admin/division/${division.id}" class="text-decoration-none d-block">
                                    <div class="stat-card stat-color-${loop.index % 20}">
                                        <div class="stat-value" style="font-size:1.4rem;">${division.localities.size()}</div>
                                        <div class="stat-label"><c:out value="${division.name}"/></div>
                                        <div class="small text-muted mt-1">
                                            <c:out value="${divisionStats[division.id]}"/> Complaints
                                        </div>
                                        <div class="small text-primary mt-1">View &rarr;</div>
                                    </div>
                                </a>
                            </div>
                        </c:forEach>
                    </div>
                </c:if>
            </c:otherwise>
        </c:choose>
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
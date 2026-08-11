<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Village Report - ${village.name}</title>
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
                    <div class="subtitle">Village Report - <c:out value="${village.name}"/></div>
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
                <h1 class="section-title">Village Report</h1>
                <p class="text-muted mb-0">
                    <i class="bi bi-geo-alt"></i> District: <c:out value="${village.district}"/>
                    <span class="ms-2" style="background:var(--primary); color:#fff; font-size:0.8rem; padding:0.35rem 0.6rem; border-radius:0.25rem; font-weight:500;">Users: ${userCount}</span>
                    <span class="ms-2" style="background:var(--accent); color:#fff; font-size:0.8rem; padding:0.35rem 0.6rem; border-radius:0.25rem; font-weight:500;">Submissions: ${complaints.size()}</span>
                </p>
            </div>
            <div>
                <c:choose>
                    <c:when test="${not empty mandalId}">
                        <a href="${pageContext.request.contextPath}/admin/mandal/${mandalId}" class="btn btn-secondary btn-sm">&larr; Back</a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-secondary btn-sm">&larr; Back</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <c:forEach var="complaint" items="${complaints}">
            <div class="card form-card mb-3">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-start mb-2">
                        <h5 class="section-title mb-0">
                            <i class="bi bi-person-circle"></i> <c:out value="${complaint.user.username}"/>
                        </h5>
                    </div>
                    <p class="text-muted mb-2">
                        <strong>Complaint Type:</strong> <c:out value="${complaint.type}"/>
                        <c:if test="${not empty complaint.otherType}">
                            <span class="badge bg-secondary ms-2"><c:out value="${complaint.otherType}"/></span>
                        </c:if>
                    </p>
                    <p class="text-muted mb-2">
                        <strong>Locality:</strong> <c:out value="${complaint.user.village.name}"/>
                    </p>
                    <p class="text-muted mb-2">
                        <strong>Submitted By:</strong> <c:out value="${complaint.user.username}"/>
                    </p>
                    <p class="mb-2">
                        <strong>Description:</strong>
                        <div class="content-preview"><c:out value="${complaint.content}"/></div>
                    </p>
                    <p class="small text-muted mb-2">Submitted on <c:out value="${complaint.createdAt}"/></p>
                    <div>
                        <strong class="text-primary">Images:</strong>
                        <div class="d-flex flex-wrap mt-2">
                            <c:forEach var="photo" items="${complaint.photos}">
                                <img src="${pageContext.request.contextPath}/photos/${photo.id}"
                                     class="photo-thumb" alt="submission photo"
                                     onclick="openLightbox(this.src)"/>
                            </c:forEach>
                            <c:if test="${empty complaint.photos}">
                                <div class="empty-state" style="padding:1.5rem;">
                                    <span class="empty-state-icon" style="font-size:2rem;"><i class="bi bi-image"></i></span>
                                    <div class="empty-state-text">No images uploaded</div>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
        </c:forEach>

        <c:if test="${empty complaints}">
            <div class="empty-state">
                <span class="empty-state-icon"><i class="bi bi-inbox"></i></span>
                <div class="empty-state-title">No submissions yet</div>
                <div class="empty-state-text">This village has not submitted any complaints yet.</div>
            </div>
        </c:if>
    </div>

    <div class="lightbox" id="lightbox" onclick="closeLightbox()">
        <span class="lightbox-close">&times;</span>
        <img id="lightboxImg" src="" alt="Full size"/>
    </div>

    <footer class="app-footer" style="background:var(--accent); color:rgba(255,255,255,0.85); padding:1.2rem 0; text-align:center; font-size:0.85rem;">
    </footer>
</div>

    <script>
<script>
    function openLightbox(src) {
        const lightbox = document.getElementById('lightbox');
        const lightboxImg = document.getElementById('lightboxImg');
        lightboxImg.src = src;
        lightbox.classList.add('active');
    }

    function closeLightbox() {
        const lightbox = document.getElementById('lightbox');
        lightbox.classList.remove('active');
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
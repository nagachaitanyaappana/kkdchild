<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Complaint Details</title>
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
                    <div class="subtitle">Complaint Details</div>
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
            <h2 class="section-title"><i class="bi bi-file-earmark-text"></i> Complaint Details</h2>
            <a href="${pageContext.request.contextPath}/admin/complaints" class="btn btn-secondary btn-sm">&larr; Back to Complaints</a>
        </div>

        <div class="card form-card mb-4">
            <div class="card-body">
                <div class="row mb-3">
                    <div class="col-md-6">
                        <strong>Complaint ID:</strong> <c:out value="${complaint.id}"/>
                    </div>

                </div>

                <div class="mb-3">
                    <strong>Complaint Type:</strong> <c:out value="${complaint.type}"/>
                    <c:if test="${not empty complaint.otherType}">
                        <span class="badge bg-secondary ms-2"><c:out value="${complaint.otherType}"/></span>
                    </c:if>
                </div>

                <div class="mb-3">
                    <strong>Locality:</strong> <c:out value="${complaint.user.village.name}"/>
                </div>

                <div class="mb-3">
                    <strong>Submitted By:</strong> <c:out value="${complaint.user.username}"/>
                </div>

                <div class="mb-3">
                    <strong>Description:</strong>
                    <div class="content-preview"><c:out value="${complaint.content}"/></div>
                </div>

                <div class="mb-3">
                    <strong>Created Date:</strong> <c:out value="${complaint.createdAt}"/>
                </div>

                <div class="mb-3">
                    <strong class="text-primary">Images:</strong>
                    <c:choose>
                        <c:when test="${not empty complaint.photos}">
                            <div class="evidence-gallery">
                                <div class="gallery-preview" onclick="openGalleryModal(0)">
                                    <img id="galleryPreviewImg" src="${pageContext.request.contextPath}/photos/${complaint.photos[0].id}" alt="Preview"/>
                                    <div class="gallery-controls">
                                        <span class="gallery-counter" id="galleryCounter">1 of ${complaint.photos.size()}</span>
                                    </div>
                                </div>
                                <div class="gallery-thumbnails">
                                    <c:forEach var="photo" items="${complaint.photos}" varStatus="loop">
                                        <img src="${pageContext.request.contextPath}/photos/${photo.id}"
                                             class="gallery-thumb ${loop.index == 0 ? 'active' : ''}"
                                             alt="Thumbnail ${loop.index + 1}"
                                             onclick="selectImage(${loop.index}, this)"/>
                                    </c:forEach>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="gallery-empty">
                                <span class="gallery-empty-icon">🖼️</span>
                                <p>No evidence images uploaded.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

    <div class="gallery-modal" id="galleryModal">
        <div class="modal-content">
            <div class="modal-image-wrapper">
                <img id="modalImg" src="" alt="Full size"/>
                <div class="modal-toolbar">
                    <button class="modal-toolbar-btn" onclick="zoomIn()" title="Zoom In">
                        <i class="bi bi-zoom-in"></i>
                    </button>
                    <button class="modal-toolbar-btn" onclick="zoomOut()" title="Zoom Out">
                        <i class="bi bi-zoom-out"></i>
                    </button>
                    <button class="modal-toolbar-btn" onclick="resetZoom()" title="Reset Zoom">
                        <i class="bi bi-arrows-angle-contract"></i>
                    </button>
                    <button class="modal-toolbar-btn" onclick="downloadImage()" title="Download">
                        <i class="bi bi-download"></i> Download
                    </button>
                </div>
                <button class="modal-close" onclick="closeGalleryModal()">&times;</button>
                <button class="modal-nav prev" onclick="prevImage()">&#10094;</button>
                <button class="modal-nav next" onclick="nextImage()">&#10095;</button>
            </div>
            <div class="modal-footer">
                <span class="modal-counter" id="modalCounter">1 of 1</span>
                <span class="modal-zoom-info" id="zoomInfo">100%</span>
            </div>
        </div>
    </div>

    <footer class="app-footer" style="background:var(--accent); color:rgba(255,255,255,0.85); padding:1.2rem 0; text-align:center; font-size:0.85rem;">
    </footer>
</div>

    <script>
<script>
    const photoUrls = [
        <c:forEach var="photo" items="${complaint.photos}" varStatus="loop">
            "${pageContext.request.contextPath}/photos/${photo.id}"<c:if test="${!loop.last}">,</c:if>
        </c:forEach>
    ];
    let currentIndex = 0;
    let currentZoom = 1;

    function selectImage(index, thumb) {
        currentIndex = index;
        currentZoom = 1;
        const preview = document.getElementById('galleryPreviewImg');
        preview.style.transform = 'scale(1)';
        preview.src = photoUrls[index];
        document.querySelectorAll('.gallery-thumb').forEach(t => t.classList.remove('active'));
        if (thumb) thumb.classList.add('active');
        document.getElementById('galleryCounter').textContent = (index + 1) + ' of ' + photoUrls.length;
    }

    function openGalleryModal(index) {
        currentIndex = index;
        currentZoom = 1;
        const modal = document.getElementById('galleryModal');
        const img = document.getElementById('modalImg');
        img.src = photoUrls[index];
        img.style.transform = 'scale(1)';
        document.getElementById('modalCounter').textContent = (index + 1) + ' of ' + photoUrls.length;
        document.getElementById('zoomInfo').textContent = '100%';
        modal.classList.add('active');
        document.addEventListener('keydown', handleKeyDown);
    }

    function closeGalleryModal() {
        document.getElementById('galleryModal').classList.remove('active');
        document.removeEventListener('keydown', handleKeyDown);
        resetZoom();
    }

    function prevImage() {
        if (photoUrls.length === 0) return;
        currentIndex = (currentIndex - 1 + photoUrls.length) % photoUrls.length;
        currentZoom = 1;
        updateModalImage();
    }

    function nextImage() {
        if (photoUrls.length === 0) return;
        currentIndex = (currentIndex + 1) % photoUrls.length;
        currentZoom = 1;
        updateModalImage();
    }

    function updateModalImage() {
        const img = document.getElementById('modalImg');
        img.style.opacity = '0';
        setTimeout(() => {
            img.src = photoUrls[currentIndex];
            img.style.transform = 'scale(1)';
            img.style.opacity = '1';
        }, 200);
        document.getElementById('modalCounter').textContent = (currentIndex + 1) + ' of ' + photoUrls.length;
        document.getElementById('zoomInfo').textContent = '100%';
    }

    function handleKeyDown(e) {
        const modal = document.getElementById('galleryModal');
        if (!modal.classList.contains('active')) return;
        if (e.key === 'Escape') closeGalleryModal();
        if (e.key === 'ArrowLeft') prevImage();
        if (e.key === 'ArrowRight') nextImage();
    }

    function zoomIn() {
        currentZoom = Math.min(currentZoom + 0.25, 3);
        applyZoom();
    }

    function zoomOut() {
        currentZoom = Math.max(currentZoom - 0.25, 0.5);
        applyZoom();
    }

    function resetZoom() {
        currentZoom = 1;
        applyZoom();
    }

    function applyZoom() {
        const img = document.getElementById('modalImg');
        img.style.transform = 'scale(' + currentZoom + ')';
        document.getElementById('zoomInfo').textContent = Math.round(currentZoom * 100) + '%';
    }

    function downloadImage() {
        const url = photoUrls[currentIndex];
        fetch(url)
            .then(res => res.blob())
            .then(blob => {
                const blobUrl = URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = blobUrl;
                a.download = 'evidence_' + (currentIndex + 1) + '.jpg';
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                URL.revokeObjectURL(blobUrl);
            })
            .catch(() => {
                window.open(url, '_blank');
            });
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
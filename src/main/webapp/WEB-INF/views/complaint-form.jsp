<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Submit Complaint</title>
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
                    <div class="brand"><c:out value="${localityName}"/> Dashboard</div>
                    <div class="subtitle">Child Welfare Monitoring System</div>
                </div>
                <ul class="nav-list">
                    <li><a href="${pageContext.request.contextPath}/complaint" class="active"><i class="bi bi-plus-circle"></i> Submit Complaint</a></li>
                    <li><a href="${pageContext.request.contextPath}/complaints/my"><i class="bi bi-list-ul"></i> My Complaints</a></li>
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

        <div class="card form-card mb-4">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h2 class="section-title"><i class="bi bi-file-earmark-text"></i> Submit Your Complaint</h2>
                    <a href="${pageContext.request.contextPath}/login" class="btn btn-secondary btn-sm">&larr; Back</a>
                </div>

                <div id="formAlert"></div>

                <div class="row g-3 mb-4">
                    <div class="col-md-3 col-sm-6">
                        <div class="info-card">
                            <div class="info-icon">&#x1F9D1;</div>
                            <div class="info-title">Child Marriage</div>
                            <div class="info-text">Report early marriage concerns</div>
                        </div>
                    </div>
                    <div class="col-md-3 col-sm-6">
                        <div class="info-card">
                            <div class="info-icon">&#x1F6E1;</div>
                            <div class="info-title">Child Safety</div>
                            <div class="info-text">Report child protection issues</div>
                        </div>
                    </div>
                    <div class="col-md-3 col-sm-6">
                        <div class="info-card">
                            <div class="info-icon">&#x1F3EB;</div>
                            <div class="info-title">Education</div>
                            <div class="info-text">Report school dropout cases</div>
                        </div>
                    </div>
                    <div class="col-md-3 col-sm-6">
                        <div class="info-card">
                            <div class="info-icon">&#x1F477;</div>
                            <div class="info-title">Child Labour</div>
                            <div class="info-text">Report children working cases</div>
                        </div>
                    </div>
                </div>

                <form id="complaintForm">
                    <div class="mb-3">
                        <label for="complaintType" class="form-label">Complaint Type</label>
                        <select class="form-select" id="complaintType" name="type" required>
                            <option value="">Select complaint type...</option>
                            <option value="CHILD_MARRIAGE">Child Marriage</option>
                            <option value="POCSO">POCSO</option>
                            <option value="CHILD_LABOUR">Child Labour</option>
                            <option value="SCHOOL_DROPOUTS">School Dropouts</option>
                            <option value="CHILD_NEGLIGENCY">Children Negligency</option>
                            <option value="HIV_INFECTION">HIV Infection</option>
                            <option value="ORPHANS">Orphans</option>
                            <option value="OTHER">Other</option>
                        </select>
                    </div>

                    <div class="mb-3" id="otherTypeGroup" style="display:none;">
                        <label for="otherType" class="form-label">Specify Issue Type</label>
                        <input type="text" class="form-control" id="otherType" name="otherType" placeholder="e.g. Child missing from home"/>
                    </div>

                    <div class="mb-3">
                        <label for="complaintContent">Complaint Details</label>
                        <textarea id="complaintContent" name="complaintContent" placeholder="Write your complaint here..." style="min-height: 220px;"></textarea>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Upload Photos</label>
                        <div class="upload-zone">
                            <i class="bi bi-cloud-upload" style="font-size: 32px; color: var(--text-secondary);"></i>
                            <div class="small text-muted mt-2">Upload Photos</div>
                            <input type="file" class="form-control form-control-sm mt-2" id="photos" name="photos" multiple accept="image/*"/>
                        </div>
                        <div class="preview-grid mt-2" id="previewGrid"></div>
                    </div>

                    <div class="mt-3 d-flex justify-content-end">
                        <button type="submit" class="btn btn-primary" id="submitComplaintBtn" onclick="setLoading('submitComplaintBtn', true)">
                            <i class="bi bi-send"></i> Submit Complaint
                        </button>
                    </div>
                </form>
            </div>
        </div>
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
    const fileInput = document.getElementById('photos');
    const previewGrid = document.getElementById('previewGrid');
    const form = document.getElementById('complaintForm');
    const formAlert = document.getElementById('formAlert');
    const complaintType = document.getElementById('complaintType');
    const otherTypeGroup = document.getElementById('otherTypeGroup');
    const otherTypeInput = document.getElementById('otherType');
    let selectedFiles = [];
    let objectUrls = new Set();

    complaintType.addEventListener('change', function () {
        if (this.value === 'OTHER') {
            otherTypeGroup.style.display = 'block';
            otherTypeInput.setAttribute('required', 'required');
        } else {
            otherTypeGroup.style.display = 'none';
            otherTypeInput.removeAttribute('required');
            otherTypeInput.value = '';
        }
    });

    fileInput.addEventListener('change', function () {
        const newFiles = Array.from(this.files).filter(f => f.type.startsWith('image/'));
        const existingNames = new Set(selectedFiles.map(f => f.name + '|' + f.size + '|' + f.lastModified));
        newFiles.forEach(f => {
            if (!existingNames.has(f.name + '|' + f.size + '|' + f.lastModified)) {
                selectedFiles.push(f);
            }
        });
        this.value = '';
        renderPreviews();
    });

    function renderPreviews() {
        previewGrid.innerHTML = '';
        selectedFiles.forEach((file, index) => {
            if (!file.type.startsWith('image/')) return;
            const url = URL.createObjectURL(file);

            const wrapper = document.createElement('div');
            wrapper.className = 'preview-item';
            wrapper.style.cssText = 'position:relative; display:inline-block;';

            const img = document.createElement('img');
            img.src = url;
            img.alt = file.name;
            img.style.cssText = 'width:80px; height:80px; object-fit:cover; border:1px solid var(--border); border-radius:0.5rem;';

            const btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'remove-btn';
            btn.innerHTML = '&times;';
            btn.title = 'Remove';
            btn.style.cssText = 'position:absolute; top:-6px; right:-6px; background:var(--danger); color:#fff; border:none; border-radius:50%; width:20px; height:20px; line-height:1; cursor:pointer;';
            btn.addEventListener('click', function (e) {
                e.preventDefault();
                e.stopPropagation();
                URL.revokeObjectURL(url);
                selectedFiles = selectedFiles.filter((_, i) => i !== index);
                renderPreviews();
            });

            wrapper.addEventListener('click', function (e) {
                if (e.target === btn || btn.contains(e.target)) return;
                openLightbox(url);
            });

            wrapper.appendChild(img);
            wrapper.appendChild(btn);
            previewGrid.appendChild(wrapper);
        });
    }

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

    function getCsrfToken() {
        const cookies = document.cookie.split(';');
        for (let i = 0; i < cookies.length; i++) {
            const parts = cookies[i].trim().split('=');
            if (parts[0] === '_csrf') {
                return decodeURIComponent(parts[1]);
            }
        }
        return null;
    }

    const ctx = "${pageContext.request.contextPath}";
    const jwt = localStorage.getItem("jwt");

    form.addEventListener('submit', function (e) {
        e.preventDefault();

        if (!jwt) {
            formAlert.innerHTML = '<div class="page-alert page-alert-error show"><i class="bi bi-exclamation-triangle-fill"></i><span>Session expired. Please log in again.</span></div>';
            return;
        }

        const type = complaintType.value;
        if (!type) {
            formAlert.innerHTML = '<div class="page-alert page-alert-error show"><i class="bi bi-exclamation-triangle-fill"></i><span>Please select a complaint type.</span></div>';
            return;
        }

        const otherType = otherTypeInput.value.trim();
        if (type === 'OTHER' && !otherType) {
            formAlert.innerHTML = '<div class="page-alert page-alert-error show"><i class="bi bi-exclamation-triangle-fill"></i><span>Please specify the issue type.</span></div>';
            return;
        }

        const complaintContent = document.getElementById('complaintContent').value.trim();
        if (!complaintContent) {
            formAlert.innerHTML = '<div class="page-alert page-alert-error show"><i class="bi bi-exclamation-triangle-fill"></i><span>Please enter complaint details.</span></div>';
            return;
        }

        const filesToSubmit = selectedFiles.length > 0 ? selectedFiles : Array.from(fileInput.files);
        if (filesToSubmit.length === 0) {
            formAlert.innerHTML = '<div class="page-alert page-alert-error show"><i class="bi bi-exclamation-triangle-fill"></i><span>Please select at least one photo.</span></div>';
            return;
        }

        const formData = new FormData();
        formData.append('complaintContent', complaintContent);
        formData.append('type', type);
        formData.append('otherType', otherType);
        filesToSubmit.forEach(file => formData.append('photos', file));

        const headers = {};
        headers['Authorization'] = 'Bearer ' + jwt;

        const csrfToken = getCsrfToken();
        if (csrfToken) {
            headers['X-CSRF-TOKEN'] = csrfToken;
        }

        fetch(ctx + '/complaint', {
            method: 'POST',
            headers: headers,
            body: formData,
            credentials: 'same-origin'
        })
        .then(res => {
            if (!res.ok) {
                return res.text().then(text => {
                    throw new Error(text || 'Submission failed');
                });
            }
            return res.text();
        })
        .then(html => {
            formAlert.innerHTML = '<div class="page-alert page-alert-success show"><i class="bi bi-check-circle-fill"></i><span>Complaint submitted successfully!</span></div>';
                            setTimeout(function() { setLoading("submitComplaintBtn", false); }, 1000);
            form.reset();
            selectedFiles = [];
            previewGrid.innerHTML = '';
            otherTypeGroup.style.display = 'none';
        })
        .catch(err => {
            console.error(err);
            formAlert.innerHTML = '<div class="page-alert page-alert-error show"><i class="bi bi-exclamation-triangle-fill"></i><span>' + (err.message || 'Submission failed. Please try again.') + '</span></div>';
                            setLoading("submitComplaintBtn", false);
        });
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
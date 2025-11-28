// Auto-dismiss flash messages after 3 seconds
function initFlashMessages() {
    setTimeout(() => {
        document.querySelectorAll('.flash').forEach(flash => {
            flash.style.opacity = '0';
            setTimeout(() => flash.remove(), 300);
        });
    }, 3000);
}

// Confirm delete actions
function initConfirmDialogs() {
    document.querySelectorAll('[data-confirm]').forEach(form => {
        form.addEventListener('submit', (e) => {
            if (!confirm(form.dataset.confirm)) {
                e.preventDefault();
            }
        });
    });
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', function () {
    initFlashMessages();
    initConfirmDialogs();
});
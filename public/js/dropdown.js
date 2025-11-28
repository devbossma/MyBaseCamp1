// Dropdown functionality
document.addEventListener('DOMContentLoaded', function () {
    const dropdownTrigger = document.getElementById('user-dropdown-trigger');
    const dropdownMenu = document.getElementById('user-dropdown-menu');

    if (dropdownTrigger && dropdownMenu) {
        dropdownTrigger.addEventListener('click', function (e) {
            e.stopPropagation();
            const isActive = dropdownTrigger.parentElement.classList.contains('active');

            document.querySelectorAll('.user-dropdown.active').forEach(dropdown => {
                dropdown.classList.remove('active');
            });

            if (!isActive) {
                dropdownTrigger.parentElement.classList.add('active');
            }
        });

        document.addEventListener('click', function (e) {
            if (!dropdownTrigger.contains(e.target) && !dropdownMenu.contains(e.target)) {
                dropdownTrigger.parentElement.classList.remove('active');
            }
        });

        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') {
                dropdownTrigger.parentElement.classList.remove('active');
            }
        });
    }
});
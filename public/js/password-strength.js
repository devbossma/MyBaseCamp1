// Password strength indicator
function initPasswordStrength() {
    const newPasswordField = document.getElementById('new_password');
    const confirmPasswordField = document.getElementById('confirm_password');

    if (newPasswordField) {
        newPasswordField.addEventListener('input', function (e) {
            const password = e.target.value;
            const strengthMeter = document.getElementById('password-strength');
            const feedback = document.getElementById('password-feedback');

            let strength = 0;
            let message = 'Very Weak';
            let color = 'var(--danger)';

            // Length check
            if (password.length >= 8) strength += 25;
            if (password.length >= 12) strength += 10;

            // Character variety checks
            if (/[A-Z]/.test(password)) strength += 20;
            if (/[0-9]/.test(password)) strength += 20;
            if (/[^A-Za-z0-9]/.test(password)) strength += 25;

            // Determine strength level
            if (strength >= 80) {
                message = 'Very Strong';
                color = 'var(--success)';
            } else if (strength >= 60) {
                message = 'Strong';
                color = 'var(--success)';
            } else if (strength >= 40) {
                message = 'Good';
                color = 'var(--warning)';
            } else if (strength >= 20) {
                message = 'Weak';
                color = 'var(--warning)';
            }

            if (strengthMeter && feedback) {
                strengthMeter.style.width = Math.min(strength, 100) + '%';
                strengthMeter.style.background = color;
                feedback.textContent = message + ' • ' + (password.length > 0 ? password.length + ' characters' : 'Enter a password to check strength');
                feedback.style.color = color;
            }
        });
    }

    if (confirmPasswordField && newPasswordField) {
        confirmPasswordField.addEventListener('input', function (e) {
            const newPassword = newPasswordField.value;
            const confirmPassword = e.target.value;

            if (confirmPassword && newPassword !== confirmPassword) {
                e.target.style.borderColor = 'var(--danger)';
                e.target.style.boxShadow = '0 0 0 3px rgba(239, 68, 68, 0.2)';
            } else {
                e.target.style.borderColor = '';
                e.target.style.boxShadow = '';
            }
        });
    }
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', initPasswordStrength);
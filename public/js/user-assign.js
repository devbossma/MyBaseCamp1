// Lightweight assignee typeahead for projects edit form
; (function () {
    function $(sel, ctx) { return (ctx || document).querySelector(sel); }
    function $all(sel, ctx) { return Array.from((ctx || document).querySelectorAll(sel)); }

    function debounce(fn, wait) {
        var t;
        return function () {
            var args = arguments, ctx = this;
            clearTimeout(t);
            t = setTimeout(function () { fn.apply(ctx, args); }, wait);
        };
    }

    function createChip(user) {
        var chip = document.createElement('div');
        chip.className = 'ua-chip';
        chip.setAttribute('data-user-id', user.id);

        var span = document.createElement('span');
        span.textContent = user.username + ' — ' + user.email;
        chip.appendChild(span);

        var btn = document.createElement('button');
        btn.type = 'button';
        btn.className = 'ua-chip-remove';
        btn.setAttribute('aria-label', 'Remove ' + user.username);
        btn.textContent = '×';
        chip.appendChild(btn);

        var hidden = document.createElement('input');
        hidden.type = 'hidden';
        hidden.name = 'project[assigned_user_ids][]';
        hidden.value = user.id;
        chip.appendChild(hidden);

        btn.addEventListener('click', function () { chip.remove(); });

        return chip;
    }

    function renderDropdown(items, container, ownerId) {
        container.innerHTML = '';
        if (!items || items.length === 0) return container.setAttribute('aria-hidden', 'true');
        items.forEach(function (u) {
            var el = document.createElement('div');
            el.className = 'ua-item';
            el.setAttribute('tabindex', '0');
            el.setAttribute('role', 'option');
            el.setAttribute('data-user-id', u.id);
            el.textContent = u.username + ' — ' + u.email;
            if (ownerId && parseInt(ownerId) === u.id) {
                el.classList.add('ua-disabled');
                el.setAttribute('aria-disabled', 'true');
            }
            container.appendChild(el);
        });
        // Make dropdown visible and style items for clarity
        container.style.display = 'block';
        container.setAttribute('aria-hidden', 'false');
        Array.from(container.querySelectorAll('.ua-item')).forEach(function (it) {
            it.style.padding = '0.4rem 0.6rem';
            it.style.cursor = 'pointer';
        });
    }

    function init(el) {
        var input = el.querySelector('#assignee-search');
        var dropdown = el.querySelector('#assignee-dropdown');
        var chips = el.querySelector('#assignee-chips');
        var ownerId = el.dataset.ownerId;

        // Delegate remove clicks on chips container (works for server-rendered and dynamically created chips)
        chips.addEventListener('click', function (ev) {
            var btn = ev.target.closest('.ua-chip-remove');
            if (!btn) return;
            var chip = btn.closest('.ua-chip');
            if (chip) chip.remove();
        });

        // Also a global delegation fallback in case chips container is replaced
        document.addEventListener('click', function (ev) {
            var btn = ev.target.closest && ev.target.closest('.ua-chip-remove');
            if (!btn) return;
            var chip = btn.closest('.ua-chip');
            if (chip) chip.remove();
        });
        var onSelect = function (user) {
            // avoid duplicates
            if (chips.querySelector('[data-user-id="' + user.id + '"]')) return;
            if (ownerId && String(ownerId) === String(user.id)) return;
            var chip = createChip(user);
            chips.appendChild(chip);
        };

        dropdown.addEventListener('click', function (ev) {
            var item = ev.target.closest('.ua-item');
            if (!item || item.classList.contains('ua-disabled')) return;
            var user = {
                id: item.getAttribute('data-user-id'),
                username: item.textContent.split(' — ')[0].trim(),
                email: item.textContent.split(' — ')[1].trim()
            };
            onSelect(user);
            input.value = '';
            dropdown.innerHTML = '';
            dropdown.setAttribute('aria-hidden', 'true');
        });

        var fetchUsers = debounce(function (q) {
            if (!q || q.length < 1) { dropdown.innerHTML = ''; dropdown.setAttribute('aria-hidden', 'true'); return; }
            console.debug('[UA] fetch users q=', q);
            fetch('/users/search?q=' + encodeURIComponent(q), { credentials: 'same-origin' })
                .then(function (r) { console.debug('[UA] response', r.status); if (!r.ok) throw r; return r.json(); })
                .then(function (json) { console.debug('[UA] json', json); renderDropdown(json, dropdown, ownerId); })
                .catch(function (err) { console.debug('[UA] fetch error', err); dropdown.innerHTML = ''; dropdown.setAttribute('aria-hidden', 'true'); });
        }, 250);

        input.addEventListener('input', function () { fetchUsers(this.value); });

        // keyboard: Enter on focused item should select
        input.addEventListener('keydown', function (e) {
            if (e.key === 'ArrowDown') {
                var first = dropdown.querySelector('.ua-item:not(.ua-disabled)');
                if (first) first.focus();
            }
        });

        // delegate keyboard navigation on dropdown
        dropdown.addEventListener('keydown', function (e) {
            var focused = document.activeElement;
            if (e.key === 'ArrowDown') {
                var next = focused.nextElementSibling; if (next) next.focus();
            } else if (e.key === 'ArrowUp') {
                var prev = focused.previousElementSibling; if (prev) prev.focus(); else input.focus();
            } else if (e.key === 'Enter') {
                focused.click();
            }
        });

        // Close dropdown when clicking outside
        document.addEventListener('click', function (ev) {
            if (!dropdown) return;
            if (ev.target === input || ev.target.closest && ev.target.closest('.ua-container')) return;
            dropdown.innerHTML = '';
            dropdown.style.display = 'none';
            dropdown.setAttribute('aria-hidden', 'true');
        });
    }

    function runInit() {
        var container = document.querySelector('.ua-container');
        if (container) init(container);
    }

    if (document.readyState === 'complete' || document.readyState === 'interactive') {
        // DOM already ready
        runInit();
    } else {
        document.addEventListener('DOMContentLoaded', runInit);
    }
})();

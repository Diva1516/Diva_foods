// --- Cookie Operations ---
function setCookie(name, value, days) {
    const d = new Date();
    d.setTime(d.getTime() + (days * 24 * 60 * 60 * 1000));
    let expires = "expires=" + d.toUTCString();
    document.cookie = name + "=" + value + ";" + expires + ";path=/";
}

function getCookie(name) {
    let nameEQ = name + "=";
    let ca = document.cookie.split(';');
    for (let i = 0; i < ca.length; i++) {
        let c = ca[i];
        while (c.charAt(0) == ' ') c = c.substring(1, c.length);
        if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length, c.length);
    }
    return "";
}

function deleteCookie(name) {
    document.cookie = name + "=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
}

// --- Session & Auth Helpers ---
function getCurrentUser() {
    return window.DIVA_USER || null;
}

function logout() {
    // Find context path depth to load logout link correctly
    const path = window.location.pathname;
    const isSubFolder = path.includes("/admin/") || path.includes("/restaurant-owner/") || path.includes("/delivery/");
    window.location.href = isSubFolder ? "../logout" : "logout";
}

function deleteUserAccount() {
    deleteCookie("username");
    sessionStorage.removeItem("user");
    localStorage.removeItem("user");
    showToast("Account deleted successfully!", "success");
    setTimeout(() => {
        window.location.href = "register.jsp";
    }, 1500);
}

// --- Theme Toggle Operations ---
const sunSvg = `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="5"></circle><line x1="12" y1="1" x2="12" y2="3"></line><line x1="12" y1="21" x2="12" y2="23"></line><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line><line x1="1" y1="12" x2="3" y2="12"></line><line x1="21" y1="12" x2="23" y2="12"></line><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line></svg>`;
const moonSvg = `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path></svg>`;

function toggleTheme() {
    const current = document.documentElement.getAttribute('data-theme');
    const next = current === 'light' ? 'dark' : 'light';
    document.documentElement.setAttribute('data-theme', next);
    localStorage.setItem('diva-theme', next);
    
    // Update theme toggle buttons
    document.querySelectorAll('.theme-toggle').forEach(btn => {
        btn.innerHTML = next === 'light' ? moonSvg : sunSvg;
    });

    // Notify other components (like Chart.js) that theme changed
    window.dispatchEvent(new Event('themeToggled'));
}

function initTheme() {
    const saved = localStorage.getItem('diva-theme') || 'dark';
    document.documentElement.setAttribute('data-theme', saved);
    document.querySelectorAll('.theme-toggle').forEach(btn => {
        btn.innerHTML = saved === 'light' ? moonSvg : sunSvg;
    });
}

// --- Cart Badge Animation ---
function updateCartBadge() {
    const badge = document.querySelector(".cart-count");
    if (badge) {
        // Add a nice pulse animation when item is updated
        badge.classList.remove("pulse-badge");
        void badge.offsetWidth; // Trigger reflow to restart CSS animation
        badge.classList.add("pulse-badge");
    }
}

// --- Dynamic Header & Footer Injection ---
function injectNavigation() {
    const header = document.querySelector("header");
    if (!header || header.innerHTML.trim() !== "") return;

    // Detect path depth to load links correctly
    const path = window.location.pathname;
    const prefix = (path.includes("/admin/") || path.includes("/restaurant-owner/") || path.includes("/delivery/")) ? "../" : "";

    const user = window.DIVA_USER || null;
    const cartCount = window.DIVA_CART_COUNT || 0;

    header.innerHTML = `
        <nav class="navbar">
            <div class="container">
                <a href="${prefix}callRestaurantServlet" class="nav-logo" style="text-decoration: none; display: flex; align-items: center; gap: 12px;">
                    <img src="${prefix}images/logo.png" alt="Diva Foods Logo" class="brand-logo-img" style="height: 44px; width: auto; object-fit: contain; border-radius: 10px;">
                    <span class="brand-text" style="font-family: var(--font-heading); font-size: 1.8rem; font-weight: 800; margin-top: -4px;">Diva Foods</span>
                </a>

                <div class="nav-links">
                    <a href="${prefix}index.jsp" class="${isActivePage('index.jsp')}">Home</a>
                    <a href="${prefix}callRestaurantServlet" class="${isActivePage('restaurants.jsp')}">Restaurants</a>
                    ${user && user.role === 'customer' ? `<a href="${prefix}orderHistory" class="${isActivePage('order-history.jsp')}">My Orders</a>` : ''}
                    ${user && user.role === 'admin' ? `<a href="${prefix}admin/dashboard" class="${isActivePage('dashboard.jsp')}">Admin Dashboard</a>` : ''}
                    ${user && user.role === 'restaurant_owner' ? `<a href="${prefix}restaurant-owner/dashboard" class="${isActivePage('dashboard.jsp')}">Owner Dashboard</a>` : ''}
                    ${user && user.role === 'delivery' ? `<a href="${prefix}delivery/dashboard" class="${isActivePage('dashboard.jsp')}">Delivery Dashboard</a>` : ''}
                </div>
                <div class="nav-actions">
                    <button class="theme-toggle" onclick="toggleTheme()" title="Toggle Theme">${sunSvg}</button>
                    ${(!user || user.role === 'customer') ? `
                        <a href="${prefix}cart.jsp" class="nav-cart" title="Shopping Cart" style="display: flex; align-items: center; gap: 4px;">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path><line x1="3" y1="6" x2="21" y2="6"></line><path d="M16 10a4 4 0 0 1-8 0"></path></svg> 
                            <span class="cart-count">${cartCount}</span>
                        </a>
                    ` : ''}
                    <div class="profile-dropdown-container">
                        <button class="profile-trigger" onclick="this.nextElementSibling.classList.toggle('show'); event.stopPropagation();">
                            <div class="profile-avatar">${user ? user.name.charAt(0).toUpperCase() : 'G'}</div>
                            <span class="profile-name">${user ? user.name.split(' ')[0] : 'Guest'}</span>
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 9l6 6 6-6"/></svg>
                        </button>
                        <div class="profile-dropdown-menu">
                            <a href="${prefix}${user ? 'profile.jsp' : 'login.jsp'}">Profile</a>
                            ${user && user.role === 'customer' ? `<a href="${prefix}orderHistory">My Orders</a>` : ''}
                            ${user && (user.role === 'admin' || user.role === 'restaurant_owner') ? `<a href="${prefix}${user.role === 'admin' ? 'admin' : 'restaurant-owner'}/orders">Orders</a>` : ''}
                            <a href="${prefix}${user ? 'profile.jsp' : 'login.jsp'}">Settings</a>
                            <div class="dropdown-divider"></div>
                            ${user ? `<a href="#" onclick="logout(); return false;">Log out</a>` : `<a href="${prefix}login.jsp">Log in</a>`}
                        </div>
                    </div>
                </div>
            </div>
        </nav>
    `;
    initTheme();

    // Close profile dropdown when clicking outside
    document.addEventListener('click', function(e) {
        const dropdown = document.querySelector('.profile-dropdown-menu');
        const trigger = document.querySelector('.profile-trigger');
        if (dropdown && dropdown.classList.contains('show') && !trigger.contains(e.target) && !dropdown.contains(e.target)) {
            dropdown.classList.remove('show');
        }
    });
}

function injectFooter() {
    const footer = document.querySelector("footer");
    if (!footer) return;

    const path = window.location.pathname;
    const prefix = (path.includes("/admin/") || path.includes("/restaurant-owner/") || path.includes("/delivery/")) ? "../" : "";

    if (footer.innerHTML.trim() !== "") return;
    
    // Do not inject large footer in dashboard layouts
    if (path.includes("/admin/") || path.includes("/restaurant-owner/") || path.includes("/delivery/")) {
        return;
    }

    if (footer.innerHTML.trim() === "") {
        footer.innerHTML = `
            <div class="container">
                <div class="footer-grid">
                    <div class="footer-col">
        <a href="${prefix}index.jsp" class="nav-logo" style="margin-bottom: 20px; text-decoration: none; display: flex; align-items: center; gap: 12px;">
            <img src="${prefix}images/logo.png" alt="Diva Foods Logo" class="brand-logo-img" style="height: 44px; width: auto; object-fit: contain; border-radius: 10px;">
            <span class="brand-text" style="font-family: var(--font-heading); font-size: 1.4rem; font-weight: 700;">Diva Foods</span>
        </a>
        <p>Delivering hot, delicious food from Bangalore's most iconic kitchens straight to your doorstep.</p>
                    </div>
                    <div class="footer-col">
                        <h4>Quick Links</h4>
                        <ul>
                            <li><a href="${prefix}index.jsp">Home</a></li>
                            <li><a href="${prefix}callRestaurantServlet">Restaurants</a></li>
                            <li><a href="${prefix}cart.jsp">View Cart</a></li>
                        </ul>
                    </div>
                    <div class="footer-col">
                        <h4>Top Cuisines</h4>
                        <ul>
                            <li><a href="${prefix}callRestaurantServlet">Biryani</a></li>
                            <li><a href="${prefix}callRestaurantServlet">South Indian</a></li>
                            <li><a href="${prefix}callRestaurantServlet">North Indian</a></li>
                            <li><a href="${prefix}callRestaurantServlet">Chinese</a></li>
                        </ul>
                    </div>
                    <div class="footer-col">
                        <h4>Support</h4>
                        <ul>
                            <li><a href="#">Contact Us</a></li>
                            <li><a href="#">Terms & Conditions</a></li>
                            <li><a href="#">Privacy Policy</a></li>
                        </ul>
                    </div>
                </div>
                <div class="footer-bottom">
                    <p>&copy; ${new Date().getFullYear()} Diva Foods. All rights reserved.</p>
                    <p>Designed with ❤️ for Bangalore Foodies</p>
                </div>
            </div>
        `;
    }
    
    // Add scroll to top button
    if (!document.getElementById('scrollToTopBtn')) {
        const scrollBtn = document.createElement('button');
        scrollBtn.id = 'scrollToTopBtn';
        scrollBtn.className = 'scroll-to-top';
        scrollBtn.innerHTML = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="19" x2="12" y2="5"></line><polyline points="5 12 12 5 19 12"></polyline></svg>';
        scrollBtn.onclick = () => window.scrollTo({ top: 0, behavior: 'smooth' });
        document.body.appendChild(scrollBtn);
        
        window.addEventListener('scroll', () => {
            if (window.scrollY > 300) {
                scrollBtn.classList.add('visible');
            } else {
                scrollBtn.classList.remove('visible');
            }
        });
    }
}

function isActivePage(filename) {
    const path = window.location.pathname;
    if (path.endsWith(filename)) return 'active';
    if (filename === 'restaurants.jsp' && path.includes('callRestaurantServlet')) return 'active';
    if (filename === 'menu.jsp' && path.includes('menu')) return 'active';
    return '';
}

function showToast(message, type = "success") {
    let toast = document.getElementById("toast");
    if (!toast) {
        toast = document.createElement("div");
        toast.id = "toast";
        toast.className = "toast";
        document.body.appendChild(toast);
    }
    toast.innerHTML = `<span>🔔</span> ${message}`;
    toast.className = `toast show ${type}`;

    setTimeout(() => {
        toast.className = "toast";
    }, 3000);
}

// --- Live Search Suggestions (Autocomplete) ---
function initSearchSuggestions() {
    const searchForm = document.querySelector('.search-form');
    if (!searchForm) return;
    
    const searchInput = searchForm.querySelector('input[name="query"]');
    if (!searchInput) return;
    
    // Create suggestions container if not present
    let suggestionsDiv = document.querySelector('.search-suggestions');
    if (!suggestionsDiv) {
        suggestionsDiv = document.createElement('div');
        suggestionsDiv.className = 'search-suggestions';
        
        // Wrap input in relative container to position absolute dropdown correctly
        const wrapper = document.createElement('div');
        wrapper.style.position = 'relative';
        wrapper.style.flex = '1';
        searchInput.parentNode.insertBefore(wrapper, searchInput);
        wrapper.appendChild(searchInput);
        wrapper.appendChild(suggestionsDiv);
    }
    
    let debounceTimer;
    searchInput.addEventListener('input', function() {
        clearTimeout(debounceTimer);
        const q = this.value.trim();
        if (q.length < 2) {
            suggestionsDiv.classList.remove('active');
            return;
        }
        
        debounceTimer = setTimeout(() => {
            // Find path depth prefix
            const path = window.location.pathname;
            const prefix = (path.includes("/admin/") || path.includes("/restaurant-owner/") || path.includes("/delivery/")) ? "../" : "";
            
            fetch(prefix + 'searchSuggest?q=' + encodeURIComponent(q))
                .then(r => r.json())
                .then(data => {
                    if (data.length === 0) {
                        suggestionsDiv.classList.remove('active');
                        return;
                    }
                    suggestionsDiv.innerHTML = '';
                    data.forEach(item => {
                        const div = document.createElement('div');
                        div.className = 'suggestion-item';
                        div.innerHTML = `<span class="suggestion-type ${item.type}">${item.type}</span><span>${item.text}</span>`;
                        div.onclick = function() {
                            if (item.type === 'restaurant') {
                                window.location.href = prefix + 'menu?restaurantID=' + item.id;
                            } else {
                                searchInput.value = item.text;
                                searchForm.submit();
                            }
                        };
                        suggestionsDiv.appendChild(div);
                    });
                    suggestionsDiv.classList.add('active');
                })
                .catch(err => console.error('Suggestions error:', err));
        }, 250);
    });
    
    // Close dropdown on click outside
    document.addEventListener('click', function(e) {
        if (!searchInput.contains(e.target) && !suggestionsDiv.contains(e.target)) {
            suggestionsDiv.classList.remove('active');
        }
    });
}

// --- Premium UI Interactions ---

// 1. Page Loader Handler
function initPageLoader() {
    const loader = document.createElement("div");
    loader.className = "page-loader-container";
    loader.innerHTML = `
        <div class="premium-3d-loader">
            <div class="ring ring1"></div>
            <div class="ring ring2"></div>
            <div class="ring ring3"></div>
            <div class="loader-core"></div>
        </div>
        <div style="font-family: 'Righteous', cursive; color: var(--text-primary); margin-top: 40px; font-size: 1.2rem; letter-spacing: 4px; text-transform: uppercase; text-shadow: 0 0 10px rgba(255,107,53,0.5);">Loading...</div>
    `;
    document.body.appendChild(loader);

    window.addEventListener("load", () => {
        setTimeout(() => {
            loader.classList.add("hidden");
            setTimeout(() => loader.remove(), 500);
        }, 600); // 600ms branded screen delay
    });
}

// 2. Click Ripple Effect on Buttons
function initButtonRipples() {
    document.addEventListener("click", (e) => {
        const btn = e.target.closest(".btn");
        if (!btn) return;

        const circle = document.createElement("span");
        circle.className = "btn-ripple";

        const rect = btn.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;

        circle.style.left = `${x}px`;
        circle.style.top = `${y}px`;

        btn.appendChild(circle);
        setTimeout(() => circle.remove(), 600);
    });
}

// 3. Scroll triggered glassmorphism navbar highlight
function initNavbarScroll() {
    const navbar = document.querySelector(".navbar");
    if (!navbar) return;

    window.addEventListener("scroll", () => {
        if (window.scrollY > 50) {
            navbar.classList.add("scrolled");
        } else {
            navbar.classList.remove("scrolled");
        }
    });
}

// 4. Scroll Reveal Intersection Observer
function initScrollReveal() {
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add("animate-fade-in");
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.15 });

    // Target cards to reveal smoothly
    document.querySelectorAll(".restaurant-card, .menu-item, .stat-card, .job-card").forEach(el => {
        observer.observe(el);
    });
}

// 5. Client-Side Sorting
function initSorting() {
    // Restaurant Sorting (by Rating)
    const restSort = document.getElementById('sortFilter');
    if (restSort) {
        restSort.addEventListener('change', function() {
            const container = document.getElementById('restaurantsContainer');
            if (!container) return;
            const cards = Array.from(container.querySelectorAll('.restaurant-card'));
            
            cards.sort((a, b) => {
                const valA = parseFloat(a.querySelector('.rating').innerText.replace('★', '').trim()) || 0;
                const valB = parseFloat(b.querySelector('.rating').innerText.replace('★', '').trim()) || 0;
                
                if (this.value === 'rating') {
                    return valB - valA; // High to Low
                }
                // default relevance (keep original DOM order if possible, though this will just leave it sorted)
                return 0; 
            });
            
            // If returning to default, simply reload the page to restore backend original order
            if (this.value === 'all') {
                window.location.reload();
                return;
            }
            
            cards.forEach(card => container.appendChild(card));
        });
    }

    // Menu Sorting (by Price)
    const menuSort = document.getElementById('menuSortFilter');
    if (menuSort) {
        menuSort.addEventListener('change', function() {
            const container = document.getElementById('menuContainer');
            if (!container) return;
            const items = Array.from(container.querySelectorAll('.menu-item'));
            
            items.sort((a, b) => {
                const priceTextA = a.querySelector('.item-price').innerText.replace('₹', '').replace(',', '').trim();
                const priceTextB = b.querySelector('.item-price').innerText.replace('₹', '').replace(',', '').trim();
                const priceA = parseFloat(priceTextA) || 0;
                const priceB = parseFloat(priceTextB) || 0;
                
                if (this.value === 'price_low') {
                    return priceA - priceB;
                } else if (this.value === 'price_high') {
                    return priceB - priceA;
                }
                return 0;
            });
            
            if (this.value === 'all') {
                window.location.reload();
                return;
            }
            
            items.forEach(item => container.appendChild(item));
        });
    }
}

// Initialize all features on DOM Load
function initAll() {
    initTheme();
    initPageLoader();
    injectNavigation();
    injectFooter();
    updateCartBadge();
    initButtonRipples();
    initNavbarScroll();
    initScrollReveal();
    initSearchSuggestions();
    initSorting();
}

if (document.readyState === 'loading') {
    document.addEventListener("DOMContentLoaded", initAll);
} else {
    initAll();
}

// Cache restore reset (bfcache back-button fix)
window.addEventListener('pageshow', (event) => {
    if (event.persisted) {
        initAll();
    }
    document.querySelectorAll('.add-to-cart-btn').forEach(btn => {
        btn.disabled = false;
        btn.textContent = 'Add to Cart';
    });
});

// 6. Advanced Swiggy/Zomato Cart Features
function handleAddToCartAjax(menuId, restaurantId, btn) {
    btn.disabled = true;
    btn.textContent = 'Adding...';

    fetch('cartServlet?action=add&menuId=' + menuId + '&restaurantId=' + restaurantId + '&quantity=1&ajax=true')
        .then(res => res.json())
        .then(data => {
            if (data.status === 'conflict') {
                btn.disabled = false;
                btn.textContent = 'Add to Cart';
                showCartConflictModal(menuId, restaurantId);
            } else if (data.status === 'success') {
                updateCartBadgeCount(data.itemCount);
                renderInlineQtyControl(menuId, restaurantId, 1);
            } else {
                btn.disabled = false;
                btn.textContent = 'Add to Cart';
                alert(data.message || 'Error adding item');
            }
        })
        .catch(err => {
            console.error(err);
            btn.disabled = false;
            btn.textContent = 'Add to Cart';
        });
}

function updateQtyAjax(menuId, restaurantId, newQty) {
    if (newQty <= 0) {
        fetch('cartServlet?action=delete&menuId=' + menuId + '&restaurantId=' + restaurantId + '&ajax=true')
            .then(res => res.json())
            .then(data => {
                if (data.status === 'success') {
                    updateCartBadgeCount(data.itemCount);
                    renderAddToCartBtn(menuId, restaurantId);
                }
            });
    } else {
        fetch('cartServlet?action=update&menuId=' + menuId + '&restaurantId=' + restaurantId + '&quantity=' + newQty + '&ajax=true')
            .then(res => res.json())
            .then(data => {
                if (data.status === 'success') {
                    updateCartBadgeCount(data.itemCount);
                    renderInlineQtyControl(menuId, restaurantId, newQty);
                }
            });
    }
}

function forceAddToCart(menuId, restaurantId) {
    fetch('cartServlet?action=add&menuId=' + menuId + '&restaurantId=' + restaurantId + '&quantity=1&force=true&ajax=true')
        .then(res => res.json())
        .then(data => {
            if (data.status === 'success') {
                closeCartConflictModal();
                // Since cart was cleared, we must reset all other active qty controls on page
                document.querySelectorAll('.inline-qty-control').forEach(ctrl => {
                    const container = ctrl.closest('.cart-action-container');
                    if (container) {
                        const parts = container.id.split('-');
                        const oldMenuId = parts[2];
                        if (oldMenuId != menuId) {
                            renderAddToCartBtn(oldMenuId, restaurantId);
                        }
                    }
                });
                updateCartBadgeCount(data.itemCount);
                renderInlineQtyControl(menuId, restaurantId, 1);
            }
        });
}

function renderInlineQtyControl(menuId, restaurantId, qty) {
    const container = document.getElementById('cart-action-' + menuId);
    if (container) {
        container.innerHTML = `<div class="inline-qty-control">
            <button type="button" class="qty-btn" onclick="updateQtyAjax(${menuId}, ${restaurantId}, ${qty - 1})">−</button>
            <span class="qty-value">${qty}</span>
            <button type="button" class="qty-btn" onclick="updateQtyAjax(${menuId}, ${restaurantId}, ${qty + 1})">+</button>
        </div>`;
    }
}

function renderAddToCartBtn(menuId, restaurantId) {
    const container = document.getElementById('cart-action-' + menuId);
    if (container) {
        container.innerHTML = `<button type="button" class="add-to-cart-btn" onclick="handleAddToCartAjax(${menuId}, ${restaurantId}, this)">Add to Cart</button>`;
    }
}

function updateCartBadgeCount(count) {
    window.DIVA_CART_COUNT = count;
    const badge = document.querySelector('.cart-count');
    if (badge) {
        badge.textContent = count;
    }
}

function showCartConflictModal(menuId, restaurantId) {
    let modal = document.getElementById('cartConflictModal');
    if (!modal) {
        modal = document.createElement('div');
        modal.id = 'cartConflictModal';
        modal.className = 'modal-overlay';
        modal.innerHTML = `<div class="modal-content animate-fade-in" style="max-width: 400px; text-align: center; background: var(--bg-card); padding: 32px; border-radius: 20px; box-shadow: var(--shadow-lg); position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); border: 1px solid var(--border);">
            <div style="font-size: 3.5rem; margin-bottom: 20px;">⚠️</div>
            <h3 style="font-family: var(--font-heading); margin-bottom: 12px; font-size: 1.5rem; color: var(--text-primary);">Items already in cart</h3>
            <p style="color: var(--text-secondary); margin-bottom: 24px;">Your cart contains items from a different restaurant. Would you like to clear the cart and add this item instead?</p>
            <div style="display: flex; gap: 12px;">
                <button class="btn" style="flex: 1; background: var(--bg-glass); color: var(--text-primary); border: 1px solid var(--border);" onclick="closeCartConflictModal()">No, cancel</button>
                <button class="btn btn-primary" style="flex: 1;" id="btnConfirmForceAdd">Yes, start anew</button>
            </div>
        </div>`;
        document.body.appendChild(modal);
    }
    
    const confirmBtn = document.getElementById('btnConfirmForceAdd');
    confirmBtn.onclick = function() { forceAddToCart(menuId, restaurantId); };
    
    // Simple inline overlay logic since we don't have separate overlay CSS
    modal.style.position = 'fixed';
    modal.style.top = '0';
    modal.style.left = '0';
    modal.style.width = '100vw';
    modal.style.height = '100vh';
    modal.style.background = 'rgba(0,0,0,0.6)';
    modal.style.backdropFilter = 'blur(5px)';
    modal.style.zIndex = '999999';
    modal.style.display = 'block';
}

function closeCartConflictModal() {
    const modal = document.getElementById('cartConflictModal');
    if (modal) {
        modal.style.display = 'none';
    }
}

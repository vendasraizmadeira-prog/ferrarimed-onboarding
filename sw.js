const CACHE = 'ferrarimed-v1';
const ASSETS = [
  '/ferrarimed-onboarding/',
  '/ferrarimed-onboarding/index.html',
  '/ferrarimed-onboarding/manifest.json',
  '/ferrarimed-onboarding/icon-192.svg',
  '/ferrarimed-onboarding/icon-512.svg',
];

// Install: cache core assets
self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE).then(c => c.addAll(ASSETS)).then(() => self.skipWaiting())
  );
});

// Activate: clean old caches
self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

// Fetch: network first, fallback to cache
self.addEventListener('fetch', e => {
  // Only handle GET requests for same origin
  if (e.request.method !== 'GET') return;

  e.respondWith(
    fetch(e.request)
      .then(res => {
        // Cache successful responses for our assets
        if (res.ok && ASSETS.some(a => e.request.url.includes(a.replace('/ferrarimed-onboarding', '')))) {
          const clone = res.clone();
          caches.open(CACHE).then(c => c.put(e.request, clone));
        }
        return res;
      })
      .catch(() => caches.match(e.request))
  );
});

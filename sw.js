/* AI 녹음노트 — 오프라인 캐시 서비스워커 */
const V = 'vn-v4';
const SHELL = [
  './',
  './index.html',
  './manifest.webmanifest',
  './icons/icon-192.png',
  './icons/icon-512.png',
  './icons/icon-maskable-512.png',
  './icons/apple-touch-icon.png'
];

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(V)
      .then(c => Promise.allSettled(SHELL.map(u => c.add(u))))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys()
      .then(ks => Promise.all(ks.filter(k => k !== V).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET') return;                          // API POST 등은 통과
  const url = new URL(req.url);
  if (url.origin !== location.origin) return;                // 외부(api.anthropic.com 등)는 캐시 안 함

  // 앱 본체(HTML)는 네트워크 우선 — 수정한 내용이 바로 반영되도록
  const isDoc = req.mode === 'navigate' || url.pathname.endsWith('/') || url.pathname.endsWith('.html');
  if (isDoc) {
    e.respondWith(
      fetch(req).then(res => {
        if (res && res.ok) { const c = res.clone(); caches.open(V).then(k => k.put(req, c)); }
        return res;
      }).catch(() => caches.match(req).then(hit => hit || caches.match('./index.html')))
    );
    return;
  }

  // 나머지 자원은 stale-while-revalidate: 캐시 먼저 → 백그라운드로 갱신
  e.respondWith(
    caches.match(req).then(hit => {
      const net = fetch(req).then(res => {
        if (res && res.ok) {
          const copy = res.clone();
          caches.open(V).then(c => c.put(req, copy));
        }
        return res;
      }).catch(() => hit);
      return hit || net;
    })
  );
});

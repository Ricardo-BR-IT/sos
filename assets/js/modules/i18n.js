const SUPPORTED_LANGS = ['en', 'pt', 'es', 'fr', 'de', 'ar', 'ru', 'zh'];
const RTL_LANGS = new Set(['ar']);

const LANG_KEY = 'sos_lang';
const NODE_KEY = 'v7_node_id';
const PROFILE_ENDPOINT = 'api/profile.php';

let activeLang = 'en';
let dictionary = {};
let loadingPromise = null;

const listeners = new Set();

function sanitizeLanguage(lang) {
  if (typeof lang !== 'string') {
    return null;
  }

  const normalized = lang.trim().toLowerCase().slice(0, 2);
  return SUPPORTED_LANGS.includes(normalized) ? normalized : null;
}

function browserLanguage() {
  return navigator.language || navigator.userLanguage || 'en';
}

function randomNodeId() {
  const seed = Math.random().toString(36).slice(2, 10).toUpperCase();
  const stamp = Date.now().toString(36).toUpperCase();
  return `NODE-${seed}-${stamp}`;
}

export function createOrGetNodeId() {
  const current = localStorage.getItem(NODE_KEY);
  if (current && current.length >= 3) {
    return current;
  }

  const next = randomNodeId();
  localStorage.setItem(NODE_KEY, next);
  return next;
}

export function getStoredLanguage() {
  return sanitizeLanguage(localStorage.getItem(LANG_KEY));
}

export function supportedLanguages() {
  return [...SUPPORTED_LANGS];
}

export function currentLanguage() {
  return activeLang;
}

export function t(key, fallback = '') {
  if (!key) {
    return fallback;
  }
  return dictionary[key] ?? fallback ?? key;
}

function setDocumentLanguage(lang) {
  document.documentElement.lang = lang;
  document.documentElement.dir = RTL_LANGS.has(lang) ? 'rtl' : 'ltr';
}

async function loadDictionary(lang) {
  if (loadingPromise && activeLang === lang) {
    return loadingPromise;
  }

  loadingPromise = fetch(`assets/i18n/${lang}.json`, { cache: 'no-cache' })
    .then((response) => {
      if (!response.ok) {
        throw new Error(`i18n ${lang} unavailable`);
      }
      return response.json();
    })
    .then((json) => {
      dictionary = json || {};
      return dictionary;
    })
    .catch(async () => {
      if (lang === 'en') {
        dictionary = {};
        return dictionary;
      }

      const fallback = await fetch('assets/i18n/en.json', { cache: 'no-cache' }).then((r) => r.json());
      dictionary = fallback || {};
      return dictionary;
    });

  return loadingPromise;
}

export function applyTranslations(root = document) {
  root.querySelectorAll('[data-i18n]').forEach((node) => {
    const key = node.dataset.i18n;
    if (!key) {
      return;
    }
    node.textContent = t(key, node.textContent || '');
  });

  root.querySelectorAll('[data-i18n-placeholder]').forEach((node) => {
    const key = node.dataset.i18nPlaceholder;
    if (!key) {
      return;
    }
    node.setAttribute('placeholder', t(key, node.getAttribute('placeholder') || ''));
  });

  root.querySelectorAll('[data-i18n-title]').forEach((node) => {
    const key = node.dataset.i18nTitle;
    if (!key) {
      return;
    }
    node.setAttribute('title', t(key, node.getAttribute('title') || ''));
  });
}

export async function fetchProfile(nodeId) {
  if (!nodeId) {
    return null;
  }

  const response = await fetch(`${PROFILE_ENDPOINT}?node_id=${encodeURIComponent(nodeId)}`, {
    cache: 'no-store',
  });

  if (!response.ok) {
    throw new Error('Unable to fetch profile');
  }

  const payload = await response.json();
  return payload.profile || null;
}

export async function syncProfile(nodeId, preference = {}) {
  if (!nodeId) {
    return null;
  }

  const payload = {
    node_id: nodeId,
    language: sanitizeLanguage(preference.language) || activeLang,
    country_detected: preference.country_detected || preference.country || null,
  };

  const response = await fetch(PROFILE_ENDPOINT, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    throw new Error('Unable to sync profile');
  }

  const result = await response.json();
  return result.profile || null;
}

export async function resolveInitialLanguage(options = {}) {
  const {
    nodeId,
    serverHintLang,
    serverHintCountry,
    navigatorLang,
  } = options;

  const localLanguage = getStoredLanguage();
  if (localLanguage) {
    return {
      language: localLanguage,
      source: 'local_storage',
      profile: null,
      country: serverHintCountry || null,
    };
  }

  if (nodeId) {
    try {
      const profile = await fetchProfile(nodeId);
      const profileLang = sanitizeLanguage(profile?.language);
      if (profileLang) {
        return {
          language: profileLang,
          source: 'server_profile',
          profile,
          country: profile?.country_detected || serverHintCountry || null,
        };
      }
    } catch (_) {
      // Keep fallback chain.
    }
  }

  const detectedByCountry = sanitizeLanguage(serverHintLang);
  if (detectedByCountry) {
    return {
      language: detectedByCountry,
      source: 'country_hint',
      profile: null,
      country: serverHintCountry || null,
    };
  }

  const detectedByBrowser = sanitizeLanguage(navigatorLang || browserLanguage()) || 'en';
  return {
    language: detectedByBrowser,
    source: 'browser',
    profile: null,
    country: serverHintCountry || null,
  };
}

export async function setLanguage(lang, options = {}) {
  const normalized = sanitizeLanguage(lang) || 'en';
  activeLang = normalized;

  await loadDictionary(normalized);
  setDocumentLanguage(normalized);
  applyTranslations(document);

  if (options.persist !== false) {
    localStorage.setItem(LANG_KEY, normalized);
  }

  if (options.nodeId) {
    try {
      await syncProfile(options.nodeId, {
        language: normalized,
        country: options.country || null,
      });
    } catch (_) {
      // Silent fallback: local preference still applies.
    }
  }

  listeners.forEach((listener) => {
    try {
      listener(normalized, dictionary);
    } catch (_) {
      // Listener errors should not break UI.
    }
  });

  return normalized;
}

export function onLanguageChange(listener) {
  listeners.add(listener);
  return () => listeners.delete(listener);
}

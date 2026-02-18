import React, { createContext, useState, useContext, useEffect } from 'react';
import { translations } from '../locales/translations';
import { languageList, rtlLocales } from '../locales/languageList';

const DEFAULT_LOCALE = 'pt';
const FALLBACK_LOCALE = 'en';

const LanguageContext = createContext();

const normalizeLocale = (value) => {
    if (!value || typeof value !== 'string') return null;
    return value.toLowerCase().replace('_', '-');
};

const baseLocale = (value) => {
    const normalized = normalizeLocale(value);
    if (!normalized) return null;
    return normalized.split('-')[0];
};

const hasLocale = (code) => languageList.some((lang) => lang.code === code);

const resolveLocale = (value) => {
    const normalized = normalizeLocale(value);
    if (!normalized) return null;
    if (translations[normalized]) return normalized;
    const base = baseLocale(normalized);
    if (base && translations[base]) return base;
    if (base && hasLocale(base)) return base;
    return null;
};

const detectLocale = () => {
    if (typeof navigator === 'undefined') return DEFAULT_LOCALE;
    const candidates = [];
    if (Array.isArray(navigator.languages)) candidates.push(...navigator.languages);
    if (navigator.language) candidates.push(navigator.language);
    const intlLocale = Intl.DateTimeFormat().resolvedOptions().locale;
    if (intlLocale) candidates.push(intlLocale);

    for (const candidate of candidates) {
        const resolved = resolveLocale(candidate);
        if (resolved) return resolved;
    }
    return DEFAULT_LOCALE;
};

const getTranslationPack = (locale) =>
    translations[locale] ||
    translations[baseLocale(locale)] ||
    translations[FALLBACK_LOCALE] ||
    translations[DEFAULT_LOCALE];

const sortedLanguages = [...languageList].sort((a, b) => {
    if (a.rank == null && b.rank == null) return a.name.localeCompare(b.name);
    if (a.rank == null) return 1;
    if (b.rank == null) return -1;
    return a.rank - b.rank;
});

export const LanguageProvider = ({ children }) => {
    const [locale, setLocale] = useState(DEFAULT_LOCALE);
    const [isAuto, setIsAuto] = useState(true);

    useEffect(() => {
        if (typeof window === 'undefined') return;
        const saved = localStorage.getItem('language');
        const resolved = saved && saved !== 'auto' ? resolveLocale(saved) : null;
        if (resolved) {
            setLocale(resolved);
            setIsAuto(false);
            return;
        }
        setLocale(detectLocale());
        setIsAuto(true);
    }, []);

    const changeLanguage = (lang) => {
        if (lang === 'auto') {
            if (typeof window !== 'undefined') {
                localStorage.removeItem('language');
            }
            setLocale(detectLocale());
            setIsAuto(true);
            return;
        }
        const resolved = resolveLocale(lang);
        if (resolved) {
            setLocale(resolved);
            setIsAuto(false);
            if (typeof window !== 'undefined') {
                localStorage.setItem('language', resolved);
            }
        }
    };

    const t = (key) => {
        const keys = key.split('.');
        let value = getTranslationPack(locale);
        for (const k of keys) {
            value = value?.[k];
        }
        return value ?? key;
    };

    const hasTranslation = Boolean(translations[locale] || translations[baseLocale(locale)]);
    const isRTL = rtlLocales.has(baseLocale(locale));

    return (
        <LanguageContext.Provider
            value={{
                locale,
                changeLanguage,
                t,
                languages: sortedLanguages,
                hasTranslation,
                isRTL,
                fallbackLocale: FALLBACK_LOCALE,
                isAuto,
            }}
        >
            {children}
        </LanguageContext.Provider>
    );
};

export const useLanguage = () => useContext(LanguageContext);

<?php

declare(strict_types=1);

if (!defined('SOS_SUPPORTED_LANGS')) {
    define('SOS_SUPPORTED_LANGS', ['en', 'pt', 'es', 'fr', 'de', 'ar', 'ru', 'zh']);
}

function sos_supported_languages(): array
{
    /** @var array<int, string> $supported */
    $supported = SOS_SUPPORTED_LANGS;
    return $supported;
}

function sos_country_from_headers(): ?string
{
    $candidates = [
        $_SERVER['HTTP_CF_IPCOUNTRY'] ?? null,
        $_SERVER['HTTP_X_COUNTRY_CODE'] ?? null,
        $_SERVER['GEOIP_COUNTRY_CODE'] ?? null,
        $_SERVER['HTTP_X_APPENGINE_COUNTRY'] ?? null,
        $_SERVER['COUNTRY_CODE'] ?? null,
    ];

    foreach ($candidates as $candidate) {
        if (!is_string($candidate)) {
            continue;
        }

        $country = strtoupper(trim($candidate));
        if (preg_match('/^[A-Z]{2}$/', $country) === 1) {
            return $country;
        }
    }

    return null;
}

function sos_language_from_country(?string $country): ?string
{
    if ($country === null || $country === '') {
        return null;
    }

    $country = strtoupper($country);

    $map = [
        'pt' => ['BR', 'PT', 'AO', 'MZ', 'CV', 'GW', 'ST', 'TL'],
        'es' => ['ES', 'MX', 'AR', 'CL', 'CO', 'PE', 'UY', 'PY', 'BO', 'EC', 'VE', 'CR', 'PA', 'DO', 'GT', 'HN', 'SV', 'NI', 'CU'],
        'fr' => ['FR', 'BE', 'CH', 'LU', 'MC', 'SN', 'CI', 'CM', 'ML', 'NE', 'CD', 'HT'],
        'de' => ['DE', 'AT', 'LI'],
        'ar' => ['SA', 'AE', 'QA', 'KW', 'BH', 'OM', 'JO', 'LB', 'EG', 'MA', 'DZ', 'TN', 'IQ', 'SY', 'YE', 'PS', 'SD'],
        'ru' => ['RU', 'BY', 'KZ', 'KG'],
        'zh' => ['CN', 'SG', 'TW', 'HK', 'MO'],
        'en' => ['US', 'GB', 'AU', 'NZ', 'IE', 'ZA', 'CA'],
    ];

    foreach ($map as $lang => $countries) {
        if (in_array($country, $countries, true)) {
            return $lang;
        }
    }

    return 'en';
}

function sos_language_from_accept_header(string $acceptLanguage): ?string
{
    $supported = sos_supported_languages();
    $chunks = explode(',', strtolower($acceptLanguage));

    foreach ($chunks as $chunk) {
        $parts = explode(';', trim($chunk));
        $locale = trim($parts[0]);
        if ($locale === '') {
            continue;
        }

        $code = substr($locale, 0, 2);
        if (in_array($code, $supported, true)) {
            return $code;
        }
    }

    return null;
}

function sos_detect_language_bootstrap(): array
{
    $country = sos_country_from_headers();
    $fromCountry = sos_language_from_country($country);
    $fromAccept = sos_language_from_accept_header($_SERVER['HTTP_ACCEPT_LANGUAGE'] ?? '');
    $supported = sos_supported_languages();

    $suggested = $fromCountry ?? $fromAccept ?? 'en';
    if (!in_array($suggested, $supported, true)) {
        $suggested = 'en';
    }

    return [
        'country' => $country,
        'language' => $suggested,
        'supported' => $supported,
    ];
}

function sos_bootstrap_json(): string
{
    return json_encode(
        sos_detect_language_bootstrap(),
        JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES
    ) ?: '{"country":null,"language":"en","supported":["en"]}';
}

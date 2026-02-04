<?php

if (!isset($_SERVER['HTTPS']) || $_SERVER['HTTPS'] !== 'on') {
    http_response_code(403);
    exit('Access Forbidden - HTTPS is required.');
}

$serverDomain = "https://endpoint.unk9vvn.com";
$serverHost = "endpoint.unk9vvn.com";

$domain = $_SERVER['HTTP_HOST'];
$ip = $_SERVER['HTTP_CF_CONNECTING_IP'] ?? $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'];
$url = $serverDomain . $_SERVER['REQUEST_URI'];
$userAgent = $_SERVER['HTTP_USER_AGENT'] ?? 'unknown';

$ch = curl_init();
curl_setopt_array($ch, [
    CURLOPT_URL => $url,
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_SSL_VERIFYPEER => true,
    CURLOPT_SSL_VERIFYHOST => 2,
    CURLOPT_HEADERFUNCTION => function($curl, $header) {
        header($header);
        return strlen($header);
    },
]);

$headers = [
    "Host: $serverHost",
    "User-Agent: $userAgent",
];

foreach ($_SERVER as $key => $value) {
    if (strpos($key, 'HTTP_') === 0) {
        $header = str_replace('_', '-', substr($key, 5));
        $headers[] = "$header: $value";
    }
}

curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);

$response = curl_exec($ch);
if (curl_errno($ch)) {
    http_response_code(500);
    exit('Internal Server Error');
}

curl_close($ch);
echo $response;

?>

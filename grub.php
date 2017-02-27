<?php

// Sorry for ugly code

define('CURDIR', __DIR__);

$file = $_SERVER['argv'][1];

if (isset($_SERVER['argv'][2])) {
	$outfile = $_SERVER['argv'][2] . '/' . basename($file, '.svg') . '-symbolic.svg';
} else {
	$outfile = CURDIR . '/' . basename($file, '.svg') . '-symbolic.svg';
}



$xml = simplexml_load_file($file);
/*
$layers = $xml->xpath("//*[contains(@id,'layer') and @inkscape:label!='Symbol' and @inkscape:label!='Icon']");
foreach($layers as $layer) {
	unset($layer[0]);
}
*/

$paths = $xml->xpath("//*[contains(@style,'fill:url(#')]");

$paths2 = $xml->xpath("//*[(contains(@style,'opacity:0.3') or contains(@style,'opacity:0.2')) and contains(@style,'fill:#000000')]");

$size = (int) $xml['width'];
if ($size <= 16) {
	$size = 16;
} elseif($size <= 24) {
	$size = 22;
} else {
	$size = 96;
}

$output = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns="http://www.w3.org/2000/svg" height="' . $size . '" width="' . $size . '" version="1.1" xmlns:cc="http://creativecommons.org/ns#" xmlns:dc="http://purl.org/dc/elements/1.1/">
';

foreach ($paths as $path) {
	//unset($path['id']);
	//$path['fill'] = '#bebebe';
	//$output .= $path->asXML();
	if (isset($path['d']))
		$output .= '<path id="' . $path['id'] . '" d="' . $path['d'] . '" fill="#bebebe" />' . "\n";
}

foreach ($paths2 as $path) {
	//unset($path['id']);
	//$path['opacity'] = '.45';
	//$path['fill'] = '#bebebe';
	//$output .= $path->asXML();
	if (isset($path['d']))
		$output .= '<path id="' . $path['id'] . '" d="' . $path['d'] . '" fill="#bebebe" opacity=".45" />' . "\n";
}

$output .= "\n</svg>";

file_put_contents($outfile, $output);

$sizes = explode("\n", shell_exec("inkscape -S '$outfile'"));
unset($sizes[0]);
array_pop($sizes);

$xml = simplexml_load_file($outfile);

foreach($sizes as $s) {
	$arr = explode(',', $s);
	//var_dump($arr); exit(1);
	if (!isset($arr[1])) {
		continue;
	}
	if (intval($arr[1]) > $size || intval($arr[2]) > $size || intval($arr[2]) < 0 || intval($arr[1]) < 0) {
		list($element) = $xml->xpath('//*[@id="' . $arr[0] . '"]');
		unset($element[0]);
	}
}

file_put_contents($outfile, $xml->asXML());







<?php

// Sorry for ugly code

define('CURDIR', __DIR__);

$file = $_SERVER['argv'][1];

if (isset($_SERVER['argv'][2])) {
	$outfile = $_SERVER['argv'][2] . '/' . basename($file, '.svg') . '.svg';
} else {
	$outfile = CURDIR . '/' . basename($file, '.svg') . '.svg';
}

$xml = simplexml_load_file($file);

$size = 96;

$output = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns="http://www.w3.org/2000/svg" height="' . $size . '" width="' . $size . '" version="1.1" xmlns:cc="http://creativecommons.org/ns#" xmlns:dc="http://purl.org/dc/elements/1.1/">
<g id="Scle" transform="scale(3)">
';

$paths = $xml->path;

foreach ($paths as $path) {
	$output .= $path->asXML();
}

$output .= "\n</g>\n</svg>";

file_put_contents($outfile, $output);

shell_exec("inkscape --file='$outfile' \
 --select=Scle --verb=AlignVerticalCenter --verb=AlignHorizontalCenter --verb=SelectionUnGroup \
 --verb=FileSave --verb=FileQuit");

shell_exec("inkscape --file='$outfile' --export-plain-svg='$outfile'");

$xml = simplexml_load_file($outfile);

$size = 96;

$output = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns="http://www.w3.org/2000/svg" height="' . $size . '" width="' . $size . '" version="1.1" xmlns:cc="http://creativecommons.org/ns#" xmlns:dc="http://purl.org/dc/elements/1.1/">
';

$paths = $xml->path;

foreach ($paths as $path) {
	$props = explode(';', $path['style']);
	foreach ($props as &$prop) {
		$prop = explode(':', $prop);
		$path[$prop[0]] = $prop[1];
	}
	unset($path['style']);
	$output .= $path->asXML();
}

$output .= "\n</svg>";
file_put_contents($outfile, $output);



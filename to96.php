<?php


define('CURDIR', __DIR__);

$file = $_SERVER['argv'][1];

$outfile = CURDIR . '/' . basename($file, '.svg') . '.svg';


$xml = simplexml_load_file($file);

$size = 96;
$scale = 4;

$output = '<svg width="' . $size . '" height="' . $size . '" version="1.1" xmlns="http://www.w3.org/2000/svg">
<g id="Scle">
';

$paths = $xml->path;

foreach ($paths as $path) {
  	$path['transform'] = "translate(16,16) scale($scale)";
	$output .= $path->asXML();
}

$output .= "\n</g>\n</svg>";

file_put_contents($outfile, $output);

shell_exec("inkscape --file='$outfile' \
 --select=Scle --verb=SelectionUnGroup \
 --verb=FileSave --verb=FileQuit");

shell_exec("inkscape --file='$outfile' --export-plain-svg='$outfile'");

$xml = simplexml_load_file($outfile);

$size = 96;

$output = '<svg width="' . $size . '" height="' . $size . '" version="1.1" xmlns="http://www.w3.org/2000/svg">
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

if (isset($_SERVER['argv'][2])) {
  copy($outfile, $_SERVER['argv'][2]);
  unlink($outfile);
}


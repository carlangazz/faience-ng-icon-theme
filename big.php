<?php

define('CURDIR', __DIR__);

if (isset($_SERVER['argv'][2])) {
  $file = CURDIR . '/' . str_replace('-symbolic', '', basename($_SERVER['argv'][1]));
} else {
  $file = CURDIR . '/' . str_replace('-symbolic', '', basename($_SERVER['argv'][1]));
}


copy($_SERVER['argv'][1], $file);

$xml = simplexml_load_file($file);

if (count($xml->path) === 1 && isset($xml->path['opacity'])) {
  if ($type === 1) {
    $xml->path['fill'] = '#000';
    $xml->path['opacity'] = '.30';
  } elseif ($type === 2) {
    $xml->path['fill'] = '#fff';
    $xml->path['opacity'] = '.40';
  }
  file_put_contents($file, $xml->asXML());
  //exit(0);
} else {

$sizes = explode(',', shell_exec("inkscape -S '$file' | head -2 | tail -1"));
$sizes[2] = floatval($sizes[2]);
$sizes[4] = floatval($sizes[4]);
/*
$output = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:xlink="http://www.w3.org/1999/xlink"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   height="' . $xml['height'] . '" width="' . $xml['width'] . '">
  <defs>
		<filter id="w">
			<feGaussianBlur stdDeviation="0.68880677"/>
		</filter>';
*/
$output = file_get_contents(CURDIR . '/96x96c.svg');
$output = str_replace('</svg>', '', $output);
$output .= '<defs>
		<filter id="w">
			<feGaussianBlur stdDeviation="0.68880677"/>
		</filter>';



  if ((string) $xml->path['fill'] === '#d40000') {
	  $output .= '
	<linearGradient id="a" gradientUnits="userSpaceOnUse" x1="8" y1="' . $sizes[2] . '" x2="8" y2="' . ($sizes[2] + $sizes[4]) . '">
	  <stop stop-color="#ad0707" offset="0"/>
	  <stop stop-color="#f75535" offset="1"/>
	</linearGradient>
  ';
  } if ((string) $xml->path['fill'] === '#ff9000') {
	  $output .= '
	<linearGradient id="a" gradientUnits="userSpaceOnUse" x1="8" y1="' . $sizes[2] . '" x2="8" y2="' . ($sizes[2] + $sizes[4]) . '">
	  <stop stop-color="#df880b" offset="0"/>
	  <stop stop-color="#f7c15a" offset="1"/>
	</linearGradient>
  ';
  } else {
  $output .= '
	<linearGradient id="a" gradientUnits="userSpaceOnUse" x1="8" y1="' . $sizes[2] . '" x2="8" y2="' . ($sizes[2] + $sizes[4]) . '">
		<stop stop-color="#1e1e1e" offset="0"/>
		<stop stop-color="#505050" offset="1"/>
	</linearGradient>
   ';
  }

  if (count($xml->path) === 2) {
	$sizes2 = explode(',', shell_exec("inkscape -S '$file' | tail -1"));
	$sizes2[2] = floatval($sizes2[2]);
	$sizes2[4] = floatval($sizes2[4]);
	  $output .= '
	<linearGradient id="b" gradientUnits="userSpaceOnUse" x1="8" y1="' . $sizes2[2] . '" x2="8" y2="' . ($sizes2[2] + $sizes2[4]) . '">
	  <stop stop-color="#ad0707" offset="0"/>
	  <stop stop-color="#f75535" offset="1"/>
	</linearGradient>
  ';
  }

  $output .= '</defs>';

  $path = clone($xml->path);
  $path['id'] = 'base';
	if (!isset($path['opacity'])) {
		$path['fill'] = 'url(#a)';
		$path['opacity'] = '.80';
	} else {
		$path['fill'] = '#000';
		$path['opacity'] = '.30';
	}
  $path['fill'] = 'url(#a)';
  $output .= $path->asXML();

  if (count($xml->path) === 2) {
	$path = clone($xml->path[1]);
	if ((string) $path['fill'] === '#d40000' || (string) $path['fill'] === '#ff9000') {
		$path['fill'] = 'url(#b)';
	} else {
		$path['fill'] = '#000';
  		$path['opacity'] = '.30';
	}
	$output .= $path->asXML();
  }

  $output .= '<g id="Bevel">';
  $path = clone($xml->path);
  $path['opacity'] = '.50';
  $path['fill'] = '#000';
  $path['filter'] = 'url(#w)';
  $output .= $path->asXML();

  $path = clone($xml->path);
  $path['opacity'] = '.50';
  $path['sodipodi:type'] = 'inkscape:offset';
  $path['inkscape:radius'] = '-1';
  $path['fill'] = '#000';
  //$path['filter'] = 'url(#w)';
  $path['inkscape:original'] = $path['d'];
  $path['transform'] = 'translate(0,1)';
  unset($path['d']);
  $output .= $path->asXML();
  $output .= '</g>';

  $output .= '<g id="BevelShadow">';
  $path = clone($xml->path);
  $path['fill'] = '#000';
  $path['opacity'] = '.4';
  //$path['filter'] = 'url(#w)';
  $output .= $path->asXML();
  $output .= '</g>';

  $output .= '<g id="BevelHighlight">';
  $path = clone($xml->path);
  $path['opacity'] = '.6';
  $path['fill'] = '#fff';
  $path['transform'] = 'translate(0,1)';
  $output .= $path->asXML();

  $path = clone($xml->path);
  $path['opacity'] = '.6';
  $path['fill'] = '#fff';
  $output .= $path->asXML();
  $output .= '</g>';


$output .= '</svg>';

file_put_contents($file, $output);
//
shell_exec("inkscape --file='$file' \
 --select=BevelHighlight --verb=SelectionUnGroup --verb=SelectionDiff --verb=EditDeselect \
 --select=Bevel --verb=SelectionUnGroup --verb=SelectionDiff \
 --select=BevelShadow --verb=SelectionUnGroup --verb=ObjectSetClipPath --verb=EditDeselect \
 --verb=FileSave --verb=FileQuit");
}

if (isset($_SERVER['argv'][2])) {
  copy($file, $_SERVER['argv'][2] . '/' . basename($file));
  unlink($file);
}

<?php

// Sorry for ugly code

define('CURDIR', __DIR__);

if (isset($_SERVER['argv'][2])) {
  $file = $_SERVER['argv'][2] . '/' . str_replace('-symbolic', '', basename($_SERVER['argv'][1]));
} else {
  $file = CURDIR . '/' . str_replace('-symbolic', '', basename($_SERVER['argv'][1]));
}

$symbolic = $_SERVER['argv'][1];


//copy($_SERVER['argv'][1], $file);

$icon = basename($_SERVER['argv'][1], '-symbolic.svg');

$xml = simplexml_load_file(CURDIR . '/96x96b.svg');
$json = json_decode(file_get_contents('/run/media/guest/Private/clones/my-icons/Faenza/apps/apps.json'), true);

$gradient = $xml->xpath('//*[@id="buttonGradient"]')[0];
$gradient->stop[1]['stop-color'] = $json[$icon]['bg']['start'];
$gradient->stop[0]['stop-color'] = $json[$icon]['bg']['end'];

$sizes = explode(',', shell_exec("inkscape -S '$symbolic' | head -2 | tail -1"));
$sizes[2] = floatval($sizes[2]);
$sizes[4] = floatval($sizes[4]);

//file_put_contents($file, $xml->asXml());
$output = $xml->asXml();
$output = str_replace('</svg>', '', $output);
$output .= '<defs>
		<filter id="w">
			<feGaussianBlur stdDeviation="0.68880677"/>
		</filter>';

$output .= '
	<linearGradient id="a" gradientUnits="userSpaceOnUse" x1="8" y1="' . $sizes[2] . '" x2="8" y2="' . ($sizes[2] + $sizes[4]) . '">
		<stop stop-color="' . $json[$icon]['fg']['start'] . '" offset="0"/>
		<stop stop-color="' . $json[$icon]['fg']['end'] . '" offset="1"/>
	</linearGradient>
   ';

$output .= '</defs>';

$xml = simplexml_load_file($symbolic);

  $path = clone($xml->path);
  $path['id'] = 'base';
	if (!isset($path['opacity'])) {
		$path['fill'] = 'url(#a)';
		//$path['opacity'] = '.80';
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
  $path['opacity'] = '.40';
  $path['fill'] = '#000';
  $path['filter'] = 'url(#w)';
  $output .= $path->asXML();

  $path = clone($xml->path);
  $path['opacity'] = '.40';
  $path['sodipodi:type'] = 'inkscape:offset';
  $path['inkscape:radius'] = '-1';
  $path['fill'] = '#000';
  //$path['filter'] = 'url(#w)';
  $path['inkscape:original'] = $path['d'];
  $path['transform'] = 'translate(0,1)';
  unset($path['d']);
  $output .= $path->asXML();
  $output .= '</g>';

  $output .= '<g id="BevelTop">';
  $path = clone($xml->path);
  $path['opacity'] = '.25';
  $path['sodipodi:type'] = 'inkscape:offset';
  $path['inkscape:radius'] = '0.5';
  $path['transform'] = 'translate(0,-1)';
  $path['fill'] = '#000';
  $path['inkscape:original'] = $path['d'];
  unset($path['d']);
  $output .= $path->asXML();

  $path = clone($xml->path);
  $path['opacity'] = '.25';
  $path['fill'] = '#000';
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
  $path['opacity'] = '.2';
  $path['fill'] = '#fff';
  $path['transform'] = 'translate(0,2)';
  $output .= $path->asXML();

  $path = clone($xml->path);
  $path['opacity'] = '.2';
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
 --select=BevelTop --verb=SelectionUnGroup --verb=SelectionDiff --verb=EditDeselect \
 --verb=FileSave --verb=FileQuit");



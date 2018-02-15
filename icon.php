<?php

define('CURDIR', __DIR__);

if ($_SERVER['argv'][1] == 'Faience-ng') {
  $type = 3;
} elseif ($_SERVER['argv'][1] == 'Faience-ng-Dark') {
  $type = 2;
} else {
  $type = 1;
}

//$type = (int) $_SERVER['argv'][1];

if (isset($_SERVER['argv'][3])) {
  $file = CURDIR . '/' . str_replace('-symbolic', '', basename($_SERVER['argv'][2]));
} else {
  $file = CURDIR . '/' . str_replace('-symbolic', '', basename($_SERVER['argv'][2]));
}


copy($_SERVER['argv'][2], $file);

$xml = simplexml_load_file($file);

if (count($xml->path) === 1 && isset($xml->path['opacity'])) {
  if ($type === 1) {
    $xml->path['fill'] = '#000';
    $xml->path['opacity'] = '.30';
  } elseif ($type === 2) {
    $xml->path['fill'] = '#fff';
    $xml->path['opacity'] = '.40';
  } elseif ($type === 3) {
    $xml->path['fill'] = '#000';
    $xml->path['opacity'] = '.20';
  }
  file_put_contents($file, $xml->asXML());
  //exit(0);
} else {

$sizes = explode(',', shell_exec("inkscape -S '$file' | head -2 | tail -1"));
$sizes[2] = floatval($sizes[2]);
$sizes[4] = floatval($sizes[4]);

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
   height="' . $xml['height'] . '" width="' . $xml['width'] . '"
   inkscape:version="0.92.1 r">
  <defs>';

if ($type === 1) {

  if ((string) $xml->path['fill'] === '#d40000') {
	  $output .= '
	<linearGradient id="a" gradientUnits="userSpaceOnUse" x1="8" y1="' . $sizes[2] . '" x2="8" y2="' . ($sizes[2] + $sizes[4]) . '">
	  <stop stop-color="#ad0707" offset="0"/>
	  <stop stop-color="#f75535" offset="1"/>
	</linearGradient>
  ';
  } elseif ((string) $xml->path['fill'] === '#008000') {
    $output .= '
  <linearGradient id="a" gradientUnits="userSpaceOnUse" x1="8" y1="' . $sizes[2] . '" x2="8" y2="' . ($sizes[2] + $sizes[4]) . '">
    <stop stop-color="#b0e929" offset="0"/>
    <stop stop-color="#7ea424" offset="1"/>
  </linearGradient>
  ';
  } elseif ((string) $xml->path['fill'] === '#ff9000') {
	  $output .= '
	<linearGradient id="a" gradientUnits="userSpaceOnUse" x1="8" y1="' . $sizes[2] . '" x2="8" y2="' . ($sizes[2] + $sizes[4]) . '">
	  <stop stop-color="#df880b" offset="0"/>
	  <stop stop-color="#f7c15a" offset="1"/>
	</linearGradient>
  ';
  } else {
  $output .= '
	<linearGradient id="a" gradientUnits="userSpaceOnUse" x1="8" y1="' . $sizes[2] . '" x2="8" y2="' . ($sizes[2] + $sizes[4]) . '">
	 <stop stop-opacity=".86275" offset="0"/>
	 <stop stop-opacity=".47059" offset="1"/>
	</linearGradient>
   ';
  }

  if (count($xml->path) === 2) {
	$sizes2 = explode(',', shell_exec("inkscape -S '$file' | tail -1"));
	$sizes2[2] = floatval($sizes2[2]);
	$sizes2[4] = floatval($sizes2[4]);
	  $output .= '
	<linearGradient id="b" gradientUnits="userSpaceOnUse" x1="8" y1="' . $sizes2[2] . '" x2="8" y2="' . ($sizes2[2] + $sizes2[4]) . '">
	  <stop stop-color="' . ((string) $xml->path[1]['fill'] === '#d40000' ? '#ad0707' : '#b0e929' ) . '" offset="0"/>
	  <stop stop-color="' . ((string) $xml->path[1]['fill'] === '#d40000' ? '#f75535' : '#7ea424' ) . '" offset="1"/>
	</linearGradient>
  ';
  }

  $output .= '</defs>';
  $output .= '<g id="Bevel">';
  $path = clone($xml->path);
  $path['opacity'] = '.15';
  $path['sodipodi:type'] = 'inkscape:offset';
  $path['inkscape:radius'] = '1';
  $path['fill'] = '#fff';
  $path['inkscape:original'] = $path['d'];
  unset($path['d']);
  $output .= $path->asXML();

  $path = clone($xml->path);
  $path['opacity'] = '.15';
  $path['fill'] = '#fff';
  $output .= $path->asXML();
  $output .= '</g>';

  $path = clone($xml->path);
  $path['id'] = 'base';
	if (!isset($path['opacity'])) {
		$path['fill'] = 'url(#a)';
	} else {
		$path['fill'] = '#000';
		$path['opacity'] = '.30';
	}
  $path['fill'] = 'url(#a)';
  $output .= $path->asXML();

  if (count($xml->path) === 2) {
	$path = clone($xml->path[1]);
	if ((string) $path['fill'] === '#d40000' || (string) $path['fill'] === '#ff9000' || (string) $path['fill'] === '#008000') {
		$path['fill'] = 'url(#b)';
	} else {
		$path['fill'] = '#000';
  		$path['opacity'] = '.30';
	}
	$output .= $path->asXML();
  }

  $output .= '<g id="BevelShadow">';
  $path = clone($xml->path);
  $path['fill'] = '#000';
  $path['opacity'] = '.5';
  $output .= $path->asXML();

  $path = clone($xml->path);
  $path['opacity'] = '.5';
  $path['fill'] = '#000';
  $path['transform'] = 'translate(0,1)';
  $output .= $path->asXML();
  $output .= '</g>';

  $output .= '<g id="BevelHighlight">';
  $path = clone($xml->path);
  $path['opacity'] = '.3';
  $path['fill'] = '#fff';
  $path['transform'] = 'translate(0,1)';
  $output .= $path->asXML();

  $path = clone($xml->path);
  $path['opacity'] = '.3';
  $path['fill'] = '#fff';
  $output .= $path->asXML();
  $output .= '</g>';


} elseif ($type === 2) {
  if ((string) $xml->path['fill'] === '#d40000') {
	$output .= '
	<linearGradient id="a" gradientUnits="userSpaceOnUse" x1="8" y1="' . $sizes[2] . '" x2="8" y2="' . ($sizes[2] + $sizes[4]) . '">
	  <stop stop-color="#f3604d" offset="0"/>
	  <stop stop-color="#c81700" offset="1"/>
	</linearGradient>
   ';
  } elseif ((string) $xml->path['fill'] === '#008000') {
    $output .= '
  <linearGradient id="a" gradientUnits="userSpaceOnUse" x1="8" y1="' . $sizes[2] . '" x2="8" y2="' . ($sizes[2] + $sizes[4]) . '">
    <stop stop-color="#b0e929" offset="0"/>
    <stop stop-color="#7ea424" offset="1"/>
  </linearGradient>
  ';
  } else {
	$output .= '
	  <linearGradient id="a" gradientUnits="userSpaceOnUse" x1="8" y1="' . $sizes[2] . '" x2="8" y2="' . ($sizes[2] + $sizes[4]) . '">
		<stop stop-color="#ebebeb" offset="0"/>
		<stop stop-color="#aaa" offset="1"/>
	  </linearGradient>
	 ';
  }

  if (count($xml->path) === 2) {
	$sizes2 = explode(',', shell_exec("inkscape -S '$file' | tail -1"));
	$sizes2[2] = floatval($sizes2[2]);
	$sizes2[4] = floatval($sizes2[4]);
	$output .= '
	<linearGradient id="b" gradientUnits="userSpaceOnUse" x1="8" y1="' . $sizes2[2] . '" x2="8" y2="' . ($sizes2[2] + $sizes2[4]) . '">
	  <stop stop-color="#f3604d" offset="0"/>
	  <stop stop-color="#c81700" offset="1"/>
	</linearGradient>
   ';
  }

  $output .= '</defs>';
  $output .= '<g id="Bevel">';
  $path = clone($xml->path);
  $path['opacity'] = '.25';
  ((string) $xml->path['fill'] !== '#bebebe') && $path['opacity'] = '.10';
  $path['fill'] = '#000';
  $path['inkscape:radius'] = '1';
  $path['inkscape:original'] = $path['d'];
  $path['sodipodi:type'] = 'inkscape:offset';
  unset($path['d']);
  $output .= $path->asXML();

  $path = clone($xml->path);
  $path['opacity'] = '.25';
  ((string) $xml->path['fill'] !== '#bebebe') && $path['opacity'] = '.10';
  $path['fill'] = '#000';
  $output .= $path->asXML();
  $output .= '</g>';

  $path = clone($xml->path);
  $path['id'] = 'base';
  $path['fill'] = 'url(#a)';
  $output .= $path->asXML();

  if (count($xml->path) === 2) {
	$path = clone($xml->path[1]);
	if ((string) $path['fill'] === '#d40000' || (string) $path['fill'] === '#ff9000' || (string) $path['fill'] === '#008000') {
		$path['fill'] = 'url(#b)';
	} else {
		$path['fill'] = '#fff';
  		$path['opacity'] = '.40';
	}
	$output .= $path->asXML();
  }

  $output .= '<g id="BevelShadow">';
  $path = clone($xml->path);
  $path['fill'] = '#fff';
  $path['opacity'] = '.6';
  ((string) $xml->path['fill'] !== '#bebebe') && $path['opacity'] = '.30';
  $output .= $path->asXML();

  $path = clone($xml->path);
  $path['opacity'] = '.6';
  ((string) $xml->path['fill'] !== '#bebebe') && $path['opacity'] = '.30';
  $path['fill'] = '#fff';
  $path['transform'] = 'translate(0,1)';
  $output .= $path->asXML();
  $output .= '</g>';

  $output .= '<g id="BevelHighlight">';
  $path = clone($xml->path);
  $path['opacity'] = '.45';
  ((string) $xml->path['fill'] !== '#bebebe') && $path['opacity'] = '.55';
  $path['fill'] = '#000';
  $path['transform'] = 'translate(0,1)';
  $output .= $path->asXML();

  $path = clone($xml->path);
  $path['opacity'] = '.45';
  ((string) $xml->path['fill'] !== '#bebebe') && $path['opacity'] = '.55';
  $path['fill'] = '#000';
  $output .= $path->asXML();
  $output .= '</g>';

} elseif ($type === 3) {
  $l = round($sizes[2]) + 1;
  $k = 10 - $l - 1;
  if ($xml['height'] <= 16) {
	  $r = 11;
	  $cx = 9;
	  $cy = 10;
  } else {
	  $r = 16;
	  $cx = 12;
	  $cy = 13;
	  $l = round($sizes[2]) + 1;
	  $k = 11 - $l;
  }
  if ((string) $xml->path['fill'] === '#d40000') {
	$output .= '
	<radialGradient id="a" gradientUnits="userSpaceOnUse" cy="' . $cy . '" cx="' . $cx . '" gradientTransform="matrix(1 0 0 .' . $k . $l . $k . $l . $k . ' 0 ' . $l . '.' . $k . $l . $k . ($l+1) . ')" r="' . $r . '">
	  <stop stop-color="#e64b36" offset="0"/>
	  <stop stop-color="#a31414" offset="1"/>
	</radialGradient>
   ';
  } elseif ((string) $xml->path['fill'] === '#008000') {
    $output .= '
  <radialGradient id="a" gradientUnits="userSpaceOnUse" cy="' . $cy . '" cx="' . $cx . '" gradientTransform="matrix(1 0 0 .' . $k . $l . $k . $l . $k . ' 0 ' . $l . '.' . $k . $l . $k . ($l+1) . ')" r="' . $r . '">
    <stop stop-color="#b0e929" offset="0"/>
    <stop stop-color="#7ea424" offset="1"/>
  </linearGradient>
  ';
  } elseif ((string) $xml->path['fill'] === '#ff9000') {
	  $output .= '
  <radialGradient id="a" gradientUnits="userSpaceOnUse" cy="' . $cy . '" cx="' . $cx . '" gradientTransform="matrix(1 0 0 .' . $k . $l . $k . $l . $k . ' 0 ' . $l . '.' . $k . $l . $k . ($l+1) . ')" r="' . $r . '">
	  <stop stop-color="#df880b" offset="0"/>
	  <stop stop-color="#f7c15a" offset="1"/>
	</linearGradient>
  ';
  } else {
  $output .= '
	<radialGradient id="a" gradientUnits="userSpaceOnUse" cy="' . $cy . '" cx="' . $cx . '" gradientTransform="matrix(1 0 0 .' . $k . $l . $k . $l . $k . ' 0 ' . $l . '.' . $k . $l . $k . ($l+1) . ')" r="' . $r . '">
	  <stop stop-opacity=".23529" offset="0"/>
	  <stop stop-opacity=".54902" offset="1"/>
	</radialGradient>
   ';
  }

  if (count($xml->path) === 2) {
	$sizes2 = explode(',', shell_exec("inkscape -S '$file' | tail -1"));
	$sizes2[2] = floatval($sizes2[2]);
	$sizes2[4] = floatval($sizes2[4]);
	  $output .= '
	<linearGradient id="b" gradientUnits="userSpaceOnUse" x1="8" y1="' . $sizes2[2] . '" x2="8" y2="' . ($sizes2[2] + $sizes2[4]) . '">
	  <stop stop-color="' . ((string) $xml->path[1]['fill'] === '#d40000' ? '#c80000' : '#0aad09' ) . '" offset="0"/>
	  <stop stop-color="' . ((string) $xml->path[1]['fill'] === '#d40000' ? '#f3604d' : '#31cb38' ) . '" offset="1"/>
	</linearGradient>
  ';
  }

  $output .= '</defs>';
  $output .= '<g id="Bevel">';
  $path = clone($xml->path);
  $path['opacity'] = '.05';
  $path['sodipodi:type'] = 'inkscape:offset';
  $path['inkscape:radius'] = '1';
  $path['fill'] = '#fff';
  $path['inkscape:original'] = $path['d'];
  unset($path['d']);
  $output .= $path->asXML();

  $path = clone($xml->path);
  $path['opacity'] = '.05';
  $path['fill'] = '#fff';
  $output .= $path->asXML();
  $output .= '</g>';

  $path = clone($xml->path);
  $path['id'] = 'base';
  $path['fill'] = 'url(#a)';
  $output .= $path->asXML();

  if (count($xml->path) === 2) {
	$path = clone($xml->path[1]);
	if ((string) $path['fill'] === '#d40000' || (string) $path['fill'] === '#ff9000' || (string) $path['fill'] === '#008000') {
		$path['fill'] = 'url(#b)';
	} else {
		$path['fill'] = '#000';
  		$path['opacity'] = '.20';
	}
	$output .= $path->asXML();
  }

  //-----------
  $output .= '<g id="BevelInner">';

  $path = clone($xml->path);
  $path['opacity'] = '.3';
  $path['fill'] = '#000';
  $output .= $path->asXML();

  $path = clone($xml->path);
  $path['opacity'] = '.3';
  $path['sodipodi:type'] = 'inkscape:offset';
  $path['inkscape:radius'] = '-0.5';
  $path['fill'] = '#000';
  $path['inkscape:original'] = $path['d'];
  unset($path['d']);
  $output .= $path->asXML();
  $output .= '</g>';

  //-----------
  $output .= '<g id="BevelShadow">';
  $path = clone($xml->path);
  $path['fill'] = '#000';
  $path['opacity'] = '.3';
  $output .= $path->asXML();

  $path = clone($xml->path);
  $path['opacity'] = '.3';
  $path['fill'] = '#000';
  $path['transform'] = 'translate(0,1)';
  $output .= $path->asXML();
  $output .= '</g>';

  $output .= '<g id="BevelHighlight">';
  $path = clone($xml->path);
  $path['opacity'] = '.2';
  $path['fill'] = '#fff';
  $path['transform'] = 'translate(0,1)';
  $output .= $path->asXML();

  $path = clone($xml->path);
  $path['opacity'] = '.2';
  $path['fill'] = '#fff';
  $output .= $path->asXML();
  $output .= '</g>';

}

$output .= '</svg>';

//file_put_contents($file . '2', $output);
file_put_contents($file, $output);
//
shell_exec("inkscape --file='$file' --select=Bevel --verb=SelectionUnGroup --verb=SelectionDiff --verb=EditDeselect \
 --select=BevelShadow --verb=SelectionUnGroup --verb=SelectionDiff --verb=EditDeselect \
 --select=BevelHighlight --verb=SelectionUnGroup --verb=SelectionDiff --verb=EditDeselect \
 --select=BevelInner --verb=SelectionUnGroup --verb=SelectionDiff --verb=EditDeselect \
 --verb=FileSave --verb=FileQuit");
}

if (isset($_SERVER['argv'][3])) {
  copy($file, $_SERVER['argv'][3] . '/' . basename($file));
  unlink($file);
}

<?php

// Sorry for ugly code

define('CURDIR', __DIR__);


$list = "folder-documents
folder-download
folder-dropbox
folder-music
folder-pictures
folder-publicshare
folder-recent
folder-remote
folder-saved-search
folder-system
folder-templates
folder-ubuntu
folder-videos
folder-wine
user-home
user-bookmarks";

$list = explode("\n", $list);

foreach ($list as $item) {

  #$file = CURDIR . '/' . str_replace('-symbolic', '', basename($_SERVER['argv'][1]));
  $file = CURDIR . '/' . $item . '.svg';
  copy(dirname($_SERVER['argv'][1]) . '/' . $item . '.svg', $file);

  $COLOR = isset($_SERVER['argv'][2]) ? $_SERVER['argv'][2] : 'folder';

  #$xml = simplexml_load_file($file);

  $simbol = file($file, FILE_IGNORE_NEW_LINES);
  array_pop($simbol);
  array_shift($simbol);

  $out = file_get_contents(dirname($_SERVER['argv'][1]) . '/' . $COLOR . '.svg');
  $out = str_replace('</svg>', '', $out);
  $out .= implode("\n", $simbol);
  $out .= '</svg>';

  if ($COLOR === 'green') {
    $out = str_replace('#bd8e48', '#6A9E47', $out);
    $out = str_replace('#aa7932', '#527838', $out);
    $out = str_replace('#7c5824', '#44652E', $out);
    $out = str_replace('#b28440', '#58843C', $out);

  } elseif ($COLOR === 'blue') {
    $out = str_replace('#bd8e48', '#6588bd', $out);
    $out = str_replace('#aa7932', '#4E688E', $out); ##5178b3
    $out = str_replace('#7c5824', '#455C80', $out);
    $out = str_replace('#b28440', '#5573A1', $out);

  }


  file_put_contents($file, $out);

}

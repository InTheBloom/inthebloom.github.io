# 非再帰かつ遅い謎のマージソート

## はじめに
practice contest B - [Interactive Sorting](https://atcoder.jp/contests/practice/tasks/practice_2)の解法を考えているときに久しぶりにマージソートを実装しました。
そのときに、非再帰でかつ実装がそんなに重くないマージソートを思いついたので紹介します。

## マージソートとは
整列済み列の結合が比較的高速にできるということを利用した分割統治による

# Changelog

## [1.1.0](https://github.com/OXY2DEV/markdoc.nvim/compare/v1.0.0...v1.1.0) (2025-11-02)


### Features

* Added API functions ([d045c49](https://github.com/OXY2DEV/markdoc.nvim/commit/d045c490a4a7cd7ff6d884169e148b12a252dcb6)), closes [#6](https://github.com/OXY2DEV/markdoc.nvim/issues/6)
* Added option to preserve whitespaces ([0aaabb7](https://github.com/OXY2DEV/markdoc.nvim/commit/0aaabb71f1088bddf201b8f1aaec308e4e8acd6d))
* Calling `setup()` is no longer required ([fb3bb01](https://github.com/OXY2DEV/markdoc.nvim/commit/fb3bb0156a07fb19feb13d9ec2639aeafd368a39)), closes [#5](https://github.com/OXY2DEV/markdoc.nvim/issues/5)
* **html:** Added `<code></code>` support ([19a339b](https://github.com/OXY2DEV/markdoc.nvim/commit/19a339bbab657fe77cad3e7868faca7150e93ee1))
* **markdown_inline:** Added `~strikethrough~` support ([ff51a9f](https://github.com/OXY2DEV/markdoc.nvim/commit/ff51a9fd7ae1a68c195653d9596f001daaa01b50))
* **markdown:** Added `setext_heading` support ([72bcca3](https://github.com/OXY2DEV/markdoc.nvim/commit/72bcca37b1806da0955c980473c17286efa320e5))
* **markdown:** Added horizontal rule support ([fbc82b5](https://github.com/OXY2DEV/markdoc.nvim/commit/fbc82b578d23d1b2799bc2a214c0401225d0b752))
* **markdown:** Allow link modofication on link/image section ([febdc0b](https://github.com/OXY2DEV/markdoc.nvim/commit/febdc0bd00f37056d72b8510484409f5c0403661))


### Bug Fixes

* Empty whitespaces are now added conditionally for footers ([d585a2a](https://github.com/OXY2DEV/markdoc.nvim/commit/d585a2a6e900f5534f225fe8b4b5001d631d584d))
* Filename is now *relative* to the source file ([df723c1](https://github.com/OXY2DEV/markdoc.nvim/commit/df723c10733c6bc060e153818e447e502234b4e8))
* Fixed a bug with incorreft filetype ([5c9b60f](https://github.com/OXY2DEV/markdoc.nvim/commit/5c9b60f6f942432f0c9ac82ad4312269a586f00a))
* Fixed whitespace logic ([3a8a760](https://github.com/OXY2DEV/markdoc.nvim/commit/3a8a7609bb295f1282b35b0dfc6c740aabb4983d))
* **format:** Remove trailing empty lines from output ([0c02140](https://github.com/OXY2DEV/markdoc.nvim/commit/0c02140773e71d06edeb33b46975dc1019c403ec))
* **html:** `ignore` now works correctly with multiple regions ([6fca043](https://github.com/OXY2DEV/markdoc.nvim/commit/6fca043f6eee5212b86633f4905060caaeac57e1))
* **html:** Added filter to ignore match captures ([8eb95fa](https://github.com/OXY2DEV/markdoc.nvim/commit/8eb95fa0ca34849a6b1fe0e1791f8c282fd764f7))
* **html:** Updated how links are transformed from HTML ([4c24659](https://github.com/OXY2DEV/markdoc.nvim/commit/4c246598595bd648006e1087bf0d4e318f9b39d4))
* Injections are no longer transformed ([45aab81](https://github.com/OXY2DEV/markdoc.nvim/commit/45aab81267227d1ffa31be6fb49f0b42b52d5473))
* **markdown_inline:** `code spans` in tables no longer break rendering ([2e69c5e](https://github.com/OXY2DEV/markdoc.nvim/commit/2e69c5e52fdd3a66865f42fc8895ffab376a0f02)), closes [#4](https://github.com/OXY2DEV/markdoc.nvim/issues/4)
* **markdown:** Fixed a bug with image section not rendering ([1ac49eb](https://github.com/OXY2DEV/markdoc.nvim/commit/1ac49eb3c6d4be2af6ac8c6289fc1956b03bb2cc))
* **markdown:** Fixed an issue with headings getting turned into code blocks ([79d32ac](https://github.com/OXY2DEV/markdoc.nvim/commit/79d32acb83af7bfac8b7a959f5cb83cf2e54259b))
* **markdown:** Fixed incorrect transform range for code blocks ([c58207e](https://github.com/OXY2DEV/markdoc.nvim/commit/c58207ef3eba18818cec543de5fd3cccc43f8790))
* **markdown:** Fixed links not showing up at bottom ([c721e40](https://github.com/OXY2DEV/markdoc.nvim/commit/c721e406506e627a1835b503787b3deb28f02ce1))
* **markdown:** Formatter now doesn't strip empty lines ([2ccb252](https://github.com/OXY2DEV/markdoc.nvim/commit/2ccb2523c8283cdd9989b0d09b3b44ba10216486))
* **markdown:** Horizontal rulss no longer break headings ([f36a7b8](https://github.com/OXY2DEV/markdoc.nvim/commit/f36a7b88aa2b4af7e3884820bc809712cd3822b0))
* **markdown:** Newlines in setext headings are now treated as space ([4ba78ef](https://github.com/OXY2DEV/markdoc.nvim/commit/4ba78efc35da9b103ab962402e7bec4b5018da92))

## 1.0.0 (2025-10-18)


### ⚠ BREAKING CHANGES

* **markdown_inline:** More flexible inline links

### Features

* Added ability to write files without confirmation ([1a3ddf4](https://github.com/OXY2DEV/markdoc.nvim/commit/1a3ddf4f0129ea8e627d76da591ba0997d6aefb0))
* Added basic support for HTML ([7fb4b74](https://github.com/OXY2DEV/markdoc.nvim/commit/7fb4b741cd70df04124fdca992b5c8d1f855a4b9))
* Added config ([ad1a206](https://github.com/OXY2DEV/markdoc.nvim/commit/ad1a206ffea0b0518a59507c4b6de5bf4735f768))
* Added export option ([e790695](https://github.com/OXY2DEV/markdoc.nvim/commit/e790695d108aedee81b5186d64776c14539f2d83))
* Added file conversion ([e4f22c4](https://github.com/OXY2DEV/markdoc.nvim/commit/e4f22c4e32b80f6b979616e207e34bc2435f6937))
* Added link & image references ([b01c363](https://github.com/OXY2DEV/markdoc.nvim/commit/b01c363d043ce62db6b3b8ce68b96a4bfcc2ecc0))
* Added TOC support ([b998338](https://github.com/OXY2DEV/markdoc.nvim/commit/b9983382769d0bf9b1d7f561bc1f804e5b325d1d))
* Draft version of `markdown_inline` -&gt; `vimdoc` converter ([ca046c0](https://github.com/OXY2DEV/markdoc.nvim/commit/ca046c0ca3590c72579193b578d213c2b3fe2b65))
* Draft version of `markdown` -&gt; `vimdoc` converter ([98ccd5c](https://github.com/OXY2DEV/markdoc.nvim/commit/98ccd5c38366253fcda3c8a4cc5c13efeca14ae8))
* **html:** Added `details` & `summary` support ([5914d76](https://github.com/OXY2DEV/markdoc.nvim/commit/5914d767f73d601ddbab12e4aeedacdc8367f05f))
* **html:** Added ability to ignore pqrts of the document ([77c9a2b](https://github.com/OXY2DEV/markdoc.nvim/commit/77c9a2bb3d96e3c23bd56617221746ff77c1d651))
* **html:** Added support for `bold`, `italic` & `keycode` ([9daf8d8](https://github.com/OXY2DEV/markdoc.nvim/commit/9daf8d8883c0caf99ccd9d3d090da0273fe01146))
* **html:** Added support for commemts, images & anchor tags ([b684739](https://github.com/OXY2DEV/markdoc.nvim/commit/b6847392b0d700fbe9f6de14d3711fede61d25a2))
* **html:** Better support for multiline html elements ([9daf8d8](https://github.com/OXY2DEV/markdoc.nvim/commit/9daf8d8883c0caf99ccd9d3d090da0273fe01146))
* **markdown_inline:** Added ability to change list markers ([732b897](https://github.com/OXY2DEV/markdoc.nvim/commit/732b8972f4e294197448ea60af2862639c794ed8))
* **markdown, html:** Added aupport for aligned paragraphs ([9bd47d3](https://github.com/OXY2DEV/markdoc.nvim/commit/9bd47d34c310dc2c131fe55193c096e2b9d0c283))
* **markdown:** Added block quote support ([c92d4eb](https://github.com/OXY2DEV/markdoc.nvim/commit/c92d4eb54d11bdd5548ecd4b58a7aef1462c7bc1))
* **markdown:** Added callout & callout title support ([ae99205](https://github.com/OXY2DEV/markdoc.nvim/commit/ae99205ef3718d6faba6c243df235b6acedf9ade))
* **markdown:** Added custom formatter ([54d056f](https://github.com/OXY2DEV/markdoc.nvim/commit/54d056f41d3a01e1afc2a043106b719df6db4493))
* **markdown:** Added table support ([a1a4d18](https://github.com/OXY2DEV/markdoc.nvim/commit/a1a4d18357a36f72bef5b93afe97a8e9523cdf0d))
* **markdown:** Better heading & tag system ([e7b779e](https://github.com/OXY2DEV/markdoc.nvim/commit/e7b779ed988a099ea7d6114b85c2522846886e62))
* **markdown:** Indented code block support ([ec3c026](https://github.com/OXY2DEV/markdoc.nvim/commit/ec3c026e640bc1a0610e3edd012f2c6e28be7558))
* **markdown:** Initial structure of the tree walker ([ff4bc62](https://github.com/OXY2DEV/markdoc.nvim/commit/ff4bc62f22250c51b0be5bec4a1e55c3c2a1b02b))
* **vimdoc:** Added header & footer suppprt ([9eef1d1](https://github.com/OXY2DEV/markdoc.nvim/commit/9eef1d1f958d22691c4b4dc4a593e125577f5904))


### Bug Fixes

* `setup()` now correctly works ([916cec0](https://github.com/OXY2DEV/markdoc.nvim/commit/916cec0be64097450689e064b6f99490b92eb304))
* **markdown, atx_headings:** Fixed an issue with level 3 heading transformation ([5fed49e](https://github.com/OXY2DEV/markdoc.nvim/commit/5fed49e7be5ed5a072d01b7df3afabd9ceea1969))
* **markdown:** Fixed formatting of Nodes that end with empty lines ([bab6ee8](https://github.com/OXY2DEV/markdoc.nvim/commit/bab6ee80028cbcb2f0c320f96dabf15f490a0c59))
* **markdown:** Fixed range, format related issues ([ec3c026](https://github.com/OXY2DEV/markdoc.nvim/commit/ec3c026e640bc1a0610e3edd012f2c6e28be7558))
* **markdown:** Headings now start at column 0 ([387139d](https://github.com/OXY2DEV/markdoc.nvim/commit/387139d4c7e7641f7ec0e6a39b3598ea52c68436))
* **markdown:** Improved formatting ([ab9f930](https://github.com/OXY2DEV/markdoc.nvim/commit/ab9f930c7416930a71cd1426a08043b87fe048b7))
* **markdown:** Nested code blocks now get correctly converted ([bab6ee8](https://github.com/OXY2DEV/markdoc.nvim/commit/bab6ee80028cbcb2f0c320f96dabf15f490a0c59))
* **markdown:** Proepr support for Column headings ([ec3c026](https://github.com/OXY2DEV/markdoc.nvim/commit/ec3c026e640bc1a0610e3edd012f2c6e28be7558))
* **markdown:** Removed trailing spaces for heading text ([4fdaccc](https://github.com/OXY2DEV/markdoc.nvim/commit/4fdaccc7f8df213033662149b16196069cd3af2b))
* **markdown:** Rixed border issues for table rows ([66977c0](https://github.com/OXY2DEV/markdoc.nvim/commit/66977c05480602ceca648f8b28901b6a80b146b1))
* **markdown:** Update tag width dynamically ([a0f2565](https://github.com/OXY2DEV/markdoc.nvim/commit/a0f25650b59a84c385c02f8e328bb4f024c0ed3a))


### Code Refactoring

* **markdown_inline:** More flexible inline links ([e81a3e9](https://github.com/OXY2DEV/markdoc.nvim/commit/e81a3e9ff009e0b0db42060aae6a258bb8036754))

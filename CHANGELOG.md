# Changelog

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

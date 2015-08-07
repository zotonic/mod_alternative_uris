# mod_alternative_uris

Define a list of alternative uris for your content.

This adds a `textarea` to the *Advanced* panel in the admin.
Define a list of different urls, paths or hostnames for the content by adding lines to this textarea.

The content of the textarea is processed during the pivot of the resource. This means that it might take a couple of minutes before the new urls are effective.

Every line is first sanitized using `z_html:sanitize_uri/1` and parsed with `mochiweb_util:urlsplit/1` before it is inserted. Only the host and path of the parsed alternative uris is taken into account. The protocol, query-string, and fragment (hash) are not used for the dispatch matching.

The alternative uris are matched after matching all configured hosts and/or dispatch rules. This means that any configuration from the site configs, dispatch rules, and resource *page_path* takes precendence.

## Zotonic version

You will need Zotonic version 0.13.2 or later. This because of changes to the *Advanced* admin panel.

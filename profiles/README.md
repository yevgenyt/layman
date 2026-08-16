# Vocabulary profiles

Starting points for `~/.config/layman/known-vocabulary` — terms Layman should never explain
back to you.

You usually don't need these. Layman's first calibration rule is that **words you have used are
words you know**, which handles most of this automatically. A profile is worth copying when you
want a term treated as known *before* you've happened to use it in a conversation.

```bash
cp profiles/backend-web.md ~/.config/layman/known-vocabulary
```

Then edit. Blank lines and `#` comments are ignored, so you can keep the section headers.

Combine freely — `cat` two profiles together and delete what doesn't apply. The list is read as
a flat set of terms; the grouping is only for your benefit.

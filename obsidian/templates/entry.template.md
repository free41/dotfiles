---
date: "{{DATE}}"
title: "{{VALUE:Title}}"
daily: "[[{{DATE:YYYY/MM/YYYY-MM-DD}}]]"
people: "{{FILE:People|link|multi|optional|label:People}}"
group: "{{FILE:Groups|link|multi|optional|label:Group}}"
related: "{{FILE:/|link|multi|optional|label:Related Notes}}"
tags: "{{FIELD:tags|multi}}"
---

# {{VALUE:Title}}

<%*
/* Link this entry in the note it was created from.
 * Runs during creation, which is before QuickAdd opens the new entry, so the
 * active file is still the note you triggered the command from. Appends at the
 * end of that note's "## Notes" section rather than at the cursor, so it never
 * lands mid-sentence. This replaces what Daily.base#Notes used to show. */
const entry = tp.config.target_file;
const host = app.workspace.getActiveFile();
if (entry && host && host.path !== entry.path) {
  const link = "- " + app.fileManager.generateMarkdownLink(entry, host.path);
  await app.vault.process(host, (body) => {
    const lines = body.split("\n");
    const heading = lines.findIndex((l) => /^##\s+Notes[ \t]*$/.test(l));
    if (heading === -1) {
      return body.replace(/\s*$/, "") + "\n\n## Notes\n\n" + link + "\n";
    }
    let at = heading + 1;
    while (at < lines.length && !/^#{1,6}\s/.test(lines[at])) at++;
    while (at > heading + 1 && lines[at - 1].trim() === "") at--;
    // Keep a blank line under the heading when the section is still empty.
    lines.splice(at, 0, ...(at === heading + 1 ? ["", link] : [link]));
    return lines.join("\n");
  });
}
%>



```dataviewjs
// Actual Note (complete relative path and name)
const currentFilePath = dv.current().file.path.replace('.md', '');
const currentFileName = dv.current().file.name;

// Search in folders with format: YYYY/MM/
const notes = dv.pages('""').filter(n => /^\d{4}\/\d{2}\/\d{4}-\d{2}-\d{2}/.test(n.file.path)).sort(n => n.file.name, 'desc');

// Obtain specific context of bullet points, headers, and YAML frontmatter
async function getContexts(file, possibleLinks) {
    const content = await dv.io.load(file.path);
    if (!content) return [];

    const lines = content.split("\n");
    const contexts = [];

    // Check YAML frontmatter (if link found, return entire note)
    if (lines[0] === '---') {
        let yamlEnd = -1;
        for (let i = 1; i < lines.length; i++) {
            if (lines[i] === '---') {
                yamlEnd = i;
                break;
            }
        }
        if (yamlEnd > 0) {
            const yamlContent = lines.slice(0, yamlEnd + 1).join("\n");
            const hasLink = possibleLinks.some(link => yamlContent.includes(`[[${link}]]`) || yamlContent.includes(`[[${link}|`));
            if (hasLink) {
                return [content]; // Return entire note
            }
        }
    }

    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        const hasLink = possibleLinks.some(link => line.includes(`[[${link}]]`) || line.includes(`[[${link}|`));

        if (hasLink) {
            // Check if it's a header
            const headerMatch = line.match(/^(#+)\s/);
            if (headerMatch) {
                const headerLevel = headerMatch[1].length;
                const section = [line];

                // Capture everything until next header of same or higher level, or horizontal rule
                for (let j = i + 1; j < lines.length; j++) {
                    const currentLine = lines[j];
                    const nextHeaderMatch = currentLine.match(/^(#+)\s/);
                    if (nextHeaderMatch && nextHeaderMatch[1].length <= headerLevel) {
                        break;
                    }
                    // Check for horizontal rule (but not YAML frontmatter)
                    if (currentLine.trim() === '---' && j > 0) {
                        section.push(currentLine);
                        break;
                    }
                    section.push(currentLine);
                }

                contexts.push(section.join("\n"));
            }
            // Check if it's a bullet point
            else if (/^\s*[-*+]\s/.test(line)) {
                let currentIndent = line.match(/^\s*/)[0].length;

                // Capture only previous parents
                const parents = [];
                let indentTracker = currentIndent;
                for (let j = i - 1; j >= 0; j--) {
                    const parentLine = lines[j];
                    const parentIndent = parentLine.match(/^\s*/)[0].length;
                    if (/^\s*[-*+]\s/.test(parentLine) && parentIndent < indentTracker) {
                        parents.unshift(parentLine);
                        indentTracker = parentIndent;
                    }
                    if (parentIndent === 0) break;
                }

                // Capture current bullet and children
                const descendants = [line];
                const baseIndent = currentIndent;
                for (let j = i + 1; j < lines.length; j++) {
                    const childLine = lines[j];
                    const childIndent = childLine.match(/^\s*/)[0].length;
                    if (/^\s*[-*+]\s/.test(childLine)) {
                        if (childIndent > baseIndent) {
                            descendants.push(childLine);
                        } else if (childIndent <= baseIndent) {
                            break;
                        }
                    } else {
                        break;
                    }
                }

                contexts.push([...parents, ...descendants].join("\n"));
            }
            // Otherwise, it's a paragraph
            else if (line.trim() !== "") {
                let para = [line];
                let j = i - 1;
                while (j >= 0 && lines[j].trim() !== "") para.unshift(lines[j--]);
                j = i + 1;
                while (j < lines.length && lines[j].trim() !== "") para.push(lines[j++]);
                contexts.push(para.join("\n"));
            }
        }
    }

    return contexts;
}

// Possible link
const possibleLinks = [currentFileName, currentFilePath];

// Embed notes
const embeds = [];
for (let note of notes) {
    const contexts = await getContexts(note.file, possibleLinks);
    contexts.forEach(context => {
        embeds.push(`# [[${note.file.path}|${note.file.name}]]\n\n> ${context.replace(/\n/g, "\n> ")}`);
    });
}

// Show results
dv.paragraph(embeds.length ? embeds.join('\n\n') : "_There are 0 references._");
```


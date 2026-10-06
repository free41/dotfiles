/*
 * deferTasks.js — QuickAdd user script
 *
 * Step 1 of the "Defer tasks to next weekly note" macro. It does only the two
 * things no built-in command can do, and leaves the rest to the Capture step:
 *
 *   - Marks every open task in the selection [>] (the Tasks plugin's
 *     "Change status to: [>]" command only ever touches the cursor's line —
 *     it reads editor.getCursor(), so it cannot do a multi-line selection).
 *   - Reads the heading the selection sits under, so the tasks can land under
 *     the same one next week. QuickAdd knows the current section internally
 *     but only exposes it as a link ({{LINKSECTION}}), not as heading text.
 *
 * Everything else — finding next week's note, creating it from the weekly
 * template, finding or adding the heading, appending the tasks — is done by
 * the Capture step that runs after this, via the variables set at the bottom.
 *
 * Variables handed to that Capture step:
 *   deferTarget   e.g. "2026/Weeks/2026-W40.md"   -> its "Capture to"
 *   deferHeading  e.g. "### Admin Stuff"          -> its "Insert after"
 *   deferTasks    the task lines, reset to "- [ ]" -> its capture format
 */

// - [ ] body   ->  1:indent 2:marker 3:status 4:body
const TASK = /^(\s*)([-*+]|\d+[.)])\s+\[([^\]])\]\s*(.*)$/;
const HEADING = /^\s{0,3}#{1,6}\s+\S/;

// Status types that count as finished, so aren't worth carrying into next week.
// In Progress, Important, Question, Review and friends are all still open work,
// so they do get deferred.
const FINISHED_TYPES = new Set(["DONE", "CANCELLED", "NON_TASK"]);

// Used if the Tasks plugin isn't there to ask: x/X done, - cancelled.
const FINISHED_FALLBACK = ["x", "X", "-"];

/* Statuses to leave alone: anything the Tasks plugin calls finished, plus [>]
 * itself so that running the macro twice doesn't defer the same task twice. */
function statusesToSkip(app) {
	const skip = new Set([">"]);

	const settings =
		app.plugins?.plugins?.["obsidian-tasks-plugin"]?.settings?.statusSettings;
	const configured = [
		...(settings?.coreStatuses ?? []),
		...(settings?.customStatuses ?? []),
	];

	if (configured.length === 0) {
		for (const symbol of FINISHED_FALLBACK) skip.add(symbol);
		return skip;
	}

	for (const status of configured) {
		if (FINISHED_TYPES.has(status?.type)) skip.add(status.symbol);
	}
	// [X] renders as checked even when only [x] is configured.
	if (skip.has("x")) skip.add("X");

	return skip;
}

// Matches the "weekly" format in Periodic Notes' settings.
const WEEKLY_FORMAT = "GGGG/[Weeks]/GGGG-[W]WW";

// Used when the selection has no heading above it at all.
const FALLBACK_HEADING = "## Weekly Tasks";

module.exports = async (params) => {
	const { app, obsidian, variables, abort } = params;

	const view = app.workspace.getActiveViewOfType(obsidian.MarkdownView);
	const editor = view?.editor;
	if (!editor) {
		return abort("Defer tasks: no open note to defer from.");
	}

	// --- Which lines did they highlight? ---------------------------------
	// With no selection this collapses to the cursor's own line, which makes
	// the macro work for a single task without selecting anything.
	const from = editor.getCursor("from");
	const to = editor.getCursor("to");
	const first = from.line;
	// A selection dragged to the start of a line stops short of that line.
	const last = to.line > first && to.ch === 0 ? to.line - 1 : to.line;

	// --- Sort them into "move this" and "leave this" ---------------------
	const skip = statusesToSkip(app);
	const sourceLines = []; // what the selection becomes, line for line
	const tasks = []; // the ones we're moving
	let leftAlone = 0;

	for (let i = first; i <= last; i++) {
		const line = editor.getLine(i);
		const task = line.match(TASK);

		if (!task) {
			sourceLines.push(line); // a heading, a note, a blank — keep as is
			continue;
		}

		const [, indent, marker, status, body] = task;
		if (skip.has(status)) {
			sourceLines.push(line);
			leftAlone++;
			continue;
		}

		sourceLines.push(`${indent}${marker} [>] ${body}`);
		tasks.push({ indent, marker, body });
	}

	if (tasks.length === 0) {
		const why = leftAlone
			? "those tasks are already done or deferred"
			: "no open tasks in the selection";
		return abort(`Defer tasks: nothing to defer — ${why}.`);
	}

	// --- Mark the originals [>], as one undo step ------------------------
	editor.replaceRange(
		sourceLines.join("\n"),
		{ line: first, ch: 0 },
		{ line: last, ch: editor.getLine(last).length },
	);

	// --- The heading the selection sits under ----------------------------
	let heading = FALLBACK_HEADING;
	for (let i = first - 1; i >= 0; i--) {
		const line = editor.getLine(i);
		if (HEADING.test(line)) {
			heading = line.trim();
			break;
		}
	}

	// --- Which weekly note counts as "next" ------------------------------
	// Run from a weekly note, "next" means the week after that note, so
	// tidying up an old week pushes forward one week rather than to today's.
	// Run from anywhere else (a daily note, usually), it means next week.
	const asWeek = window.moment(view.file?.basename ?? "", "GGGG-[W]WW", true);
	const base = asWeek.isValid() ? asWeek : window.moment();
	const target = base.clone().add(1, "week").format(WEEKLY_FORMAT);

	// --- Hand off to the Capture step ------------------------------------
	// Deepest common indent is stripped, so a nested task moved on its own
	// starts at the left margin instead of hanging off nothing.
	const outdent = Math.min(...tasks.map((t) => t.indent.length));

	variables.deferTarget = `${target}.md`;
	variables.deferHeading = heading;
	variables.deferTasks = tasks
		.map((t) => `${t.indent.slice(outdent)}${t.marker} [ ] ${t.body}`)
		.join("\n");

	new obsidian.Notice(
		`Deferring ${tasks.length} task${tasks.length === 1 ? "" : "s"}` +
			` to ${base.clone().add(1, "week").format("GGGG-[W]WW")}` +
			`${leftAlone ? ` (${leftAlone} left alone)` : ""}`,
	);
};

import importlib.util
import pathlib
import tomllib
import unittest

script = pathlib.Path(__file__).with_name("collie-launchers.py")
spec = importlib.util.spec_from_file_location("launchers", script)
launchers = importlib.util.module_from_spec(spec)
spec.loader.exec_module(launchers)


# The keys stock Collie reads in launchers.toml; anything else needs a patched Collie.
COLLIE_KEYS = {"command", "label", "cwd", "harness", "no_prompts"}


class MobileHandoffTests(unittest.TestCase):
    def test_handoff_names_exact_session_and_target(self):
        source = {"id": "session-one", "source": "claude", "account": "cc3", "title": "rupa-prototype"}
        target = {"target": "cx1", "remainingPercent": 65, "recommended": True}
        rows = tomllib.loads(launchers.block([], [target], [source]))["launchers"]
        self.assertEqual(rows[0]["command"], "exec agb open session-one --target cx1 --safe")
        # Stock Collie shows only the label, so it alone says from where, to where and what.
        self.assertIn("rupa-prototype", rows[0]["label"])
        self.assertIn("CC3", rows[0]["label"])
        self.assertIn("CX1", rows[0]["label"])
        self.assertNotIn("agb-continue", rows[0]["command"])

    def test_rows_use_only_keys_stock_collie_reads(self):
        source = {"id": "one", "source": "claude", "account": "cc3", "title": "First"}
        rows = tomllib.loads(launchers.block([source], [{"target": "cx1"}], [source]))["launchers"]
        for row in rows:
            self.assertLessEqual(set(row), COLLIE_KEYS)

    def test_yolo_variant_is_marked_in_its_label(self):
        source = {"id": "one", "source": "claude", "account": "cc3", "title": "First"}
        for rows in (tomllib.loads(launchers.block([source], []))["launchers"],
                     tomllib.loads(launchers.block([], [{"target": "cx1"}], [source]))["launchers"]):
            safe, yolo = rows
            self.assertNotIn("YOLO", safe["label"])
            self.assertEqual(yolo["label"], safe["label"] + " · YOLO")

    def test_five_recent_sessions_by_default(self):
        self.assertEqual(launchers.DEFAULT_ROWS, 5)

    def test_multiple_sources_remain_distinct(self):
        sources = [
            {"id": "one", "source": "claude", "account": "cc3", "title": "First"},
            {"id": "two", "source": "claude", "account": "cc3", "title": "Second"},
        ]
        rows = tomllib.loads(launchers.block([], [{"target": "cx1"}], sources))["launchers"]
        self.assertEqual([row["command"] for row in rows], [
            "exec agb open one --target cx1 --safe", "exec agb open one --target cx1 --yolo",
            "exec agb open two --target cx1 --safe", "exec agb open two --target cx1 --yolo"])

    def test_resumes_have_explicit_permission_variants(self):
        source = {"id": "one", "source": "claude", "account": "cc3", "title": "First"}
        rows = tomllib.loads(launchers.block([source], []))["launchers"]
        self.assertEqual([row["command"] for row in rows], [
            "exec agb open one --safe", "exec agb open one --yolo"])

    def test_own_account_is_never_resumed_twice(self):
        source = {"id": "one", "source": "claude", "account": "cc3", "title": "First"}
        document = tomllib.loads(launchers.block([], [{"target": "cc3"}], [source]))
        self.assertNotIn("launchers", document)

    def test_pane_identity_selects_running_conversation(self):
        sessions = [{"id": "one", "source": "claude", "account": "cc3", "title": "Transcript"},
                    {"id": "two", "source": "codex", "account": "cx1", "title": "Other", "openPid": 42}]
        panes = [{"agent": "claude", "title": "rupa-prototype", "agent_session": {"value": "one"}}]
        found = launchers.running_sessions(sessions, panes)
        self.assertEqual([session["id"] for session in found], ["one", "two"])
        self.assertEqual(found[0]["title"], "rupa-prototype")
        self.assertEqual(launchers.recent_sessions(8, sessions, panes), [])

    def test_existing_operator_rows_are_preserved(self):
        existing = '[[launchers]]\ncommand = "exec custom-launcher"\nlabel = "Custom action"\n'
        generated = launchers.block([], [], [])
        self.assertTrue(launchers.splice(existing, generated).startswith(existing))


if __name__ == "__main__":
    unittest.main()

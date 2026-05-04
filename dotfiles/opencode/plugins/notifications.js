export const NotificationPlugin = async ({ project, client, $, directory, worktree }) => {
  const p = project?.name || "opencode"

  const sendNotify = async (title, msg) => {
    const fullTitle = `${p}: ${title}`
    const body = `${msg}`

    try {
      await $`notify-send "${fullTitle}" "${body}" 2>/dev/null`
    } catch {
      try {
        await $`dunstify "${fullTitle}" "${body}" 2>/dev/null`
      } catch {
        try {
          await $`zenity --notification --title "${fullTitle}" --text "${body}" 2>/dev/null`
        } catch { }
      }
    }
  }

  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        await sendNotify("Agent idle", "Task complete or waiting")
      } else if (event.type === "permission.asked") {
        await sendNotify("Input needed", "Permission required")
      } else if (event.type === "session.status" && event.status === "waiting_for_input") {
        await sendNotify("Input needed", "Agent waiting for your response")
      } else if (event.type === "session.error") {
        await sendNotify("Error", event.error?.message || "Session error")
      }
    },
  }
}

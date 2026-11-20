import { Plugin, Skill } from "@opencode/plugin"

import { matchesWorkflowChange } from "./patterns.mjs"

const DIRECTIVE = `[workflow reflection]
The user is stating a durable workflow preference or correction. Follow the reflect skill now.
If the change is explicit (from now on, always, never, remember this, make this the default), apply the smallest patch to the relevant skill, run the skills repository tests, and report the diff and commit.
If the change is exploratory (maybe, what do you think, could we), propose the patch and ask one question.
If the message also contains a task, finish that task first unless the workflow change affects it.`

type SkillLike = {
  id: string | { toString(): string }
}

// ctx.skill.list returns { location, data }.
function toSkillList(value: unknown): SkillLike[] {
  if (Array.isArray(value)) {
    return value as SkillLike[]
  }
  if (value && typeof value === "object") {
    const data = (value as { data?: unknown }).data
    if (Array.isArray(data)) {
      return data as SkillLike[]
    }
  }
  return []
}

export default Plugin.define({
  id: "reflect-trigger",
  async setup(ctx) {
    const registration = await ctx.session.hook("prompt", async (event) => {
      const text = event.prompt.text ?? ""
      if (!matchesWorkflowChange(text)) {
        return
      }

      const listed = toSkillList(await ctx.skill.list())
      const available = listed.map((skill) => String(skill.id))
      if (!available.includes("reflect")) {
        return
      }

      event.prompt.skills ??= []
      if (!event.prompt.skills.some((skill) => String(skill.id) === "reflect")) {
        event.prompt.skills.push({ id: Skill.ID.make("reflect") })
      }
      event.prompt.text = `${text}\n\n${DIRECTIVE}`
    })

    return () => registration.dispose()
  },
})

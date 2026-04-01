# Gears Page Implementation Plan

## Context
Add a "Gears" page to the portfolio (inspired by [ramx.in/gears](https://ramx.in/gears)) that showcases the devices, web extensions, and software used for development. This gives visitors insight into the tools behind the work.

## Files to Create

### 1. `src/constants/gears.ts` — Gear data
- Define `GearItem` type: `{ name: string; href: string; description?: string }`
- Define `GearSection` type: `{ title: string; items: GearItem[] }`
- Export `gearSections` array with 3 sections:
  - **Devices & Accessories** — items with optional descriptions (MacBook, monitor, keyboard, mouse, etc.)
  - **Web Extensions** — numbered list (uBlock Origin, React DevTools, daily.dev, etc.)
  - **Software** — numbered list (VS Code, Notion, Arc Browser, Warp, etc.)
- All placeholder data — easy to swap later

### 2. `src/components/gears-list.tsx` — Client component for rendering gear sections
- `'use client'` (uses motion animations)
- Import `gearSections` from `@/constants/gears` and `SectionHeading` from `./section-heading`
- For each section:
  - Wrap in `div` with existing section styles: `my-4 border-neutral-100 border-y px-4 py-6 shadow-section-inset dark:border-neutral-800 dark:shadow-section-inset-dark`
  - Render `<SectionHeading delay={sectionIdx * 0.3 + 0.2}>{title}</SectionHeading>`
  - List items with staggered `motion.a` animations matching existing pattern:
    - `initial={{ opacity: 0, filter: 'blur(10px)', y: 10 }}`
    - `whileInView={{ opacity: 1, filter: 'blur(0px)', y: 0 }}`
    - `transition={{ duration: 0.3, delay: idx * 0.1, ease: 'easeInOut' }}`
  - Each item: flex row with name (+ optional description below) and external link icon
  - "Web Extensions" and "Software" sections show numbered items
  - Links open in new tab (`target="_blank"`, `rel="noopener noreferrer"`)
  - Use Lucide `ArrowUpRight` icon for external link indicator

### 3. `src/app/gears/page.tsx` — Page route (server component)
- Follow exact page pattern: `Container > Scales > Heading("Gears") > Subheading > GearsList`
- Export metadata with title and description

## File to Modify

### 4. `src/components/navbar/index.tsx` — Add nav item
- Add `{ title: 'Gears', href: '/gears' }` after "Blog" and before "Contact" in the `navItems` array
- Both desktop and mobile navbars auto-render from this array — no other changes needed

## Verification
1. Run `npm run dev` and navigate to `/gears`
2. Confirm page renders with heading, subheading, and 3 gear sections
3. Confirm staggered animations play on scroll
4. Confirm external links open in new tabs
5. Confirm "Gears" appears in both desktop and mobile navbars
6. Test dark mode toggle on the gears page
7. Run `npm run build` to verify no build errors

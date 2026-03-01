# Realistic CSS Shadows

Generate layered box-shadows that simulate real light behavior with umbra (dark center) and penumbra (soft outer edge).

## Core Principle: The Doubling Pattern

Stack 3-6 shadows with exponentially increasing offset and blur:

```css
box-shadow:
  0 1px 1px rgba(0,0,0,0.12),   /* 1x - contact */
  0 2px 2px rgba(0,0,0,0.12),   /* 2x - near */
  0 4px 4px rgba(0,0,0,0.12),   /* 4x - mid */
  0 8px 8px rgba(0,0,0,0.12),   /* 8x - far */
  0 16px 16px rgba(0,0,0,0.12); /* 16x - ambient */
```

**Opacity math**: 4 layers → ~15% each | 5 layers → ~12% | 6 layers → ~10%

## Shadow Recipes by Elevation

### Low (1-3dp): Subtle lift for resting cards

```css
box-shadow:
  0 1px 2px rgba(0,0,0,0.05),
  0 1px 3px rgba(0,0,0,0.1);
```

### Medium (4-8dp): Floating cards, elevated containers

```css
box-shadow:
  0 1px 1px rgba(0,0,0,0.08),
  0 2px 4px rgba(0,0,0,0.08),
  0 4px 8px rgba(0,0,0,0.06),
  0 8px 16px rgba(0,0,0,0.04);
```

### High (16-24dp): Modals, dropdowns, popovers

```css
box-shadow:
  0 11px 15px -7px rgba(0,0,0,0.20),
  0 24px 38px 3px rgba(0,0,0,0.14),
  0 9px 46px 8px rgba(0,0,0,0.12);
```

### Dramatic (8-layer maximum depth)

```css
--shadow-color: 220 3% 15%;

box-shadow:
  0.3px 0.5px 0.7px hsl(var(--shadow-color) / 0.34),
  1.5px 2.9px 3.7px -0.4px hsl(var(--shadow-color) / 0.34),
  2.7px 5.4px 6.8px -0.7px hsl(var(--shadow-color) / 0.34),
  4.5px 8.9px 11.2px -1.1px hsl(var(--shadow-color) / 0.34),
  7.1px 14.3px 18px -1.4px hsl(var(--shadow-color) / 0.34),
  11.2px 22.3px 28.1px -1.8px hsl(var(--shadow-color) / 0.34),
  17px 33.9px 42.7px -2.1px hsl(var(--shadow-color) / 0.34),
  25px 50px 62.9px -2.5px hsl(var(--shadow-color) / 0.34);
```

## Special Patterns

### Bottom-only shadow (no side spill)

```css
box-shadow:
  0 2px 2px -1px rgba(0,0,0,0.1),
  0 4px 6px -2px rgba(0,0,0,0.08);
/* Negative spread prevents side overflow */
```

### Inset/recessed appearance

```css
box-shadow: inset 0 1px 2px rgba(0,0,0,0.05);
```

### Parent/child hierarchy

```css
/* Parent - elevated */
.parent {
  z-index: 2;
  box-shadow:
    0 1px 1px rgba(0,0,0,0.08),
    0 2px 4px rgba(0,0,0,0.08),
    0 4px 8px rgba(0,0,0,0.06);
}

/* Child - flat or recessed */
.child {
  z-index: 1;
  box-shadow: none; /* or inset 0 1px 2px rgba(0,0,0,0.05) */
}
```

## CSS Custom Properties System

```css
:root {
  --shadow-color: 220 3% 15%;
  --shadow-strength: 1%;

  --shadow-xs: 0 1px 2px hsl(var(--shadow-color) / calc(var(--shadow-strength) + 9%));

  --shadow-sm:
    0 1px 3px hsl(var(--shadow-color) / calc(var(--shadow-strength) + 10%)),
    0 1px 2px hsl(var(--shadow-color) / calc(var(--shadow-strength) + 6%));

  --shadow-md:
    0 4px 6px -1px hsl(var(--shadow-color) / calc(var(--shadow-strength) + 10%)),
    0 2px 4px -1px hsl(var(--shadow-color) / calc(var(--shadow-strength) + 6%));

  --shadow-lg:
    0 10px 15px -3px hsl(var(--shadow-color) / calc(var(--shadow-strength) + 10%)),
    0 4px 6px -2px hsl(var(--shadow-color) / calc(var(--shadow-strength) + 5%));

  --shadow-xl:
    0 20px 25px -5px hsl(var(--shadow-color) / calc(var(--shadow-strength) + 10%)),
    0 10px 10px -5px hsl(var(--shadow-color) / calc(var(--shadow-strength) + 4%));
}

/* Dark mode */
.dark {
  --shadow-color: 220 40% 2%;
  --shadow-strength: 25%;
}
```

## Tailwind Config Extension

```javascript
module.exports = {
  theme: {
    extend: {
      boxShadow: {
        'elevation-1': '0 1px 2px rgba(0,0,0,0.05)',
        'elevation-2': '0 1px 3px rgba(0,0,0,0.1), 0 1px 2px rgba(0,0,0,0.06)',
        'elevation-3': '0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -1px rgba(0,0,0,0.06)',
        'elevation-4': '0 10px 15px -3px rgba(0,0,0,0.1), 0 4px 6px -2px rgba(0,0,0,0.05)',
      }
    }
  }
}
```

## Performance Guidelines

- **Limit to 3-5 layers** for most use cases
- **Keep blur under 20px** on mobile
- **Never animate box-shadow directly** - each frame triggers repaint

### Animated elevation (GPU-accelerated)

```css
.card {
  position: relative;
  transition: transform 0.2s ease;
}

.card::after {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: inherit;
  box-shadow: 0 20px 40px rgba(0,0,0,0.3);
  opacity: 0;
  transition: opacity 0.2s ease;
  z-index: -1;
}

.card:hover {
  transform: translateY(-4px);
}

.card:hover::after {
  opacity: 1;
}
```

## Best Practices

1. **Match shadow color to background hue** - `hsl(220deg 60% 50% / 0.3)` looks more natural than pure black on colored backgrounds
2. **Consistent light direction** - typically top-left, shadows bottom-right with ~2:1 vertical-to-horizontal offset
3. **Elevation = offset + blur + opacity fade** working together, not just darkness
4. **Layer purposes**: Contact (crisp edge) → Near diffuse → Mid-range → Outer ambient

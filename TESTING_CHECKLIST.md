# Godot 4.x Migration Testing Checklist

## Pre-Testing Setup

- [ ] Project opens in Godot 4.x without critical errors
- [ ] All scene files have been auto-converted by the editor
- [ ] Export templates for Godot 4.x are installed
- [ ] Mobile device is connected for testing (if testing mobile)

## Core Gameplay Systems

### Slingshot Mechanics
- [ ] Slingshot can be grabbed with mouse click (desktop)
- [ ] Slingshot can be grabbed with touch (mobile)
- [ ] Slingshot shows trajectory when pulled
- [ ] Slingshot launches projectile when released
- [ ] Launch force corresponds to pull distance
- [ ] Elastic animations play correctly

### Projectile Physics
- [ ] FaceProjectile spawns correctly
- [ ] Projectile follows physics trajectory
- [ ] Projectile trail particles work
- [ ] Squash/stretch effects work on impact
- [ ] Projectile can destroy props
- [ ] Almost stopped signal fires correctly

### Destructible Props
- [ ] Props take damage from projectile impacts
- [ ] Damage sprites update as health decreases
- [ ] Props shake when hit
- [ ] Props destroy when health reaches zero
- [ ] Destruction effects play
- [ ] Rubble chunks spawn correctly
- [ ] Destruction sounds play

### Rubble System
- [ ] Rubble chunks spawn with random positions/velocities
- [ ] Rubble settles after a short time
- [ ] Settled rubble becomes static (walkable)
- [ ] Rubble snaps to grid for stable platforming
- [ ] Rubble is added to "walkable_rubble" group

### StickClone Platformer
- [ ] StickClone spawns in ENTERING state
- [ ] Walks to launch point correctly
- [ ] Transitions to TRAVERSING state
- [ ] Left/Right movement works (keyboard)
- [ ] Left/Right movement works (touch virtual controls if implemented)
- [ ] Jump works and feels responsive
- [ ] Gravity applies correctly
- [ ] Character lands on rubble chunks
- [ ] Climb prompt appears near rubble
- [ ] Climbing works when pressing interact key
- [ ] Character reaches top of rubble
- [ ] Facing direction updates correctly
- [ ] Animations update based on state

### Room System
- [ ] Room loads correctly
- [ ] All props are placed properly
- [ ] Exit door appears
- [ ] Exit door unlocks when conditions met
- [ ] Room completion is tracked
- [ ] Next room loads on completion
- [ ] Room state persists correctly

## UI/Menus

### Main Menu
- [ ] Main menu displays correctly
- [ ] All buttons are clickable
- [ ] Button hover effects work
- [ ] Menu navigation works
- [ ] "Start Game" loads game
- [ ] "Customization" opens customization menu
- [ ] Clouds animate in background
- [ ] Music plays

### Customization System
- [ ] Face capture dialog opens
- [ ] File dialog works for image selection
- [ ] Image preview displays
- [ ] Eye/mouth markers can be placed
- [ ] Face data saves to profile
- [ ] Cosmetic menu displays options
- [ ] Cosmetics can be selected
- [ ] Cosmetics preview on character
- [ ] Changes save to profile

### HUD/Score
- [ ] Score displays correctly
- [ ] Score updates when props destroyed
- [ ] Combo counter works
- [ ] Rage meter fills correctly
- [ ] All UI elements scale properly on different resolutions

## Audio

- [ ] Background music plays on menu
- [ ] Background music plays in game
- [ ] Music loops correctly
- [ ] Hit sounds play when props damaged
- [ ] Destroy sounds play when props destroyed
- [ ] Slingshot sounds work
- [ ] Volume can be adjusted
- [ ] Mute works correctly

## Mobile-Specific Testing

### Touch Input
- [ ] Slingshot responds to touch drag
- [ ] Touch release launches projectile
- [ ] Multi-touch doesn't cause issues
- [ ] Virtual buttons work (if implemented)
- [ ] UI buttons respond to touch
- [ ] No accidental touches detected

### Screen Layout
- [ ] Game fills screen properly
- [ ] UI scales correctly on phone screens
- [ ] UI scales correctly on tablet screens
- [ ] Portrait mode works (if supported)
- [ ] Landscape mode works
- [ ] Notch/cutout areas handled properly
- [ ] Safe areas respected

### Performance
- [ ] Game runs at 60 FPS on target devices
- [ ] No significant frame drops
- [ ] Memory usage is reasonable
- [ ] Battery drain is acceptable
- [ ] No overheating issues
- [ ] Loading times are reasonable

### Device Features
- [ ] Back button handled correctly (Android)
- [ ] App pause/resume works correctly
- [ ] Permissions handled properly
- [ ] App icon displays correctly
- [ ] Splash screen shows (if configured)

## Edge Cases & Bugs

### Physics
- [ ] Objects don't fall through floors
- [ ] No infinite velocity issues
- [ ] Collision detection is accurate
- [ ] No jittering or stuttering
- [ ] Ragdoll physics work (if applicable)

### State Management
- [ ] Game state persists through scene changes
- [ ] Profile data saves and loads correctly
- [ ] Progress is tracked properly
- [ ] No data corruption

### Error Handling
- [ ] Missing assets don't crash game
- [ ] Invalid input handled gracefully
- [ ] Network errors handled (if applicable)
- [ ] Save/load errors handled

## Performance Benchmarks

### Desktop
- [ ] Consistent 60+ FPS
- [ ] Memory usage < 500MB
- [ ] CPU usage < 30%
- [ ] Startup time < 3 seconds

### Mobile (Mid-Range Device)
- [ ] Consistent 60 FPS
- [ ] Memory usage < 200MB
- [ ] Battery drain < 10%/hour
- [ ] Startup time < 5 seconds

### Mobile (Low-End Device)
- [ ] Minimum 30 FPS
- [ ] Memory usage < 150MB
- [ ] No crashes
- [ ] Playable experience

## Regression Testing

### After Each Fix
- [ ] Re-test the fixed issue
- [ ] Test related systems
- [ ] Run through main game loop
- [ ] Check for new issues introduced

## Final Checks

- [ ] All critical bugs fixed
- [ ] All gameplay systems functional
- [ ] Performance meets requirements
- [ ] No console errors during normal play
- [ ] Game is fun and playable
- [ ] Ready for release

## Test Devices

Document which devices were tested:

### Desktop
- [ ] Windows 10/11
- [ ] macOS
- [ ] Linux

### Mobile
- [ ] Android 11+ (specify device models)
- [ ] iOS 14+ (if applicable, specify device models)

### Browsers (Web Export)
- [ ] Chrome
- [ ] Firefox
- [ ] Safari
- [ ] Edge

## Known Issues

List any known issues that are not critical:

1. 
2. 
3. 

## Notes

Add any additional notes about the testing process:

- 
- 
- 

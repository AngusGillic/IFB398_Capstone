PET_UNLOCKS = {
    'puppy': 0, 'koala': 5, 'frill': 10, 'kanga': 18, 'wombat': 28,
    'quokka': 45, 'echidna': 65, 'platypus': 90, 'cockatoo': 130,
    'cassowary': 200,
}

ITEMS = {
    'small_pot': {'price': 25, 'durable': True},
    'water': {'price': 5, 'durable': False},
    'fertiliser': {'price': 10, 'durable': False},
    'kennel': {'price': 50, 'durable': True},

    # Backgrounds
    'room2': {'price': 100, 'durable': True},
    'room3': {'price': 150, 'durable': True},

    # Rugs
    'flowerrug': {'price': 40, 'durable': True},
    'pinkrug': {'price': 40, 'durable': True},

    # Plants
    'plant1': {'price': 25, 'durable': True},
    'plant2': {'price': 30, 'durable': True},
    'plant3': {'price': 35, 'durable': True},
    'plant4': {'price': 40, 'durable': True},
    'plant5': {'price': 45, 'durable': True},

    # Left slot
    'house1': {'price': 50, 'durable': True},
    'house2': {'price': 65, 'durable': True},
    'house3': {'price': 80, 'durable': True},
    'petbed': {'price': 45, 'durable': True},

    # Top-right slot
    'cattree': {'price': 70, 'durable': True},
    'lamp1': {'price': 35, 'durable': True},
    'lamp2': {'price': 45, 'durable': True},

    # Extras
    'ball': {'price': 15, 'durable': True},
    'bone': {'price': 10, 'durable': False},
}

ACTIONS = {
    'water': {'item': 'water', 'effects': {'health': 0.1, 'happiness': 0.05}},
    'fertiliser': {'item': 'fertiliser', 'effects': {'health': 0.2}},
    'sunlight': {'cooldown_seconds': 3600, 'effects': {'energy': 0.15}},
}

COINS_PER_KG = 10

CARE_DECAY_PER_HOUR = {'happiness': 0.02, 'energy': 0.04, 'health': 0.01}
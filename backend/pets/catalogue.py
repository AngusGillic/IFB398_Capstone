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
}

ACTIONS = {
    'water': {'item': 'water', 'effects': {'health': 0.1, 'happiness': 0.05}},
    'fertiliser': {'item': 'fertiliser', 'effects': {'health': 0.2}},
    'sunlight': {'cooldown_seconds': 3600, 'effects': {'energy': 0.15}},
}

COINS_PER_KG = 10

CARE_DECAY_PER_HOUR = {'happiness': 0.02, 'energy': 0.04, 'health': 0.01}

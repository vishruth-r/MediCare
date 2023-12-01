import 'package:flutter/material.dart';

class PillsScreen extends StatefulWidget {
  const PillsScreen({Key? key}) : super(key: key);

  @override
  _PillsScreenState createState() => _PillsScreenState();
}

class _PillsScreenState extends State<PillsScreen> {
  List<Pill> pills = [
    Pill(
      name: 'Dolo 650',
      image: 'assets/medicine1.jpeg',
      price: 10.0,
      quantity: 30,
      description: 'For headache and fever',
    ),
    Pill(
      name: 'Paracetamol',
      image: 'assets/medicine2.jpeg',
      price: 15.0,
      quantity: 20,
      description: 'For cold and cough',
    ),
    Pill(
      name: 'Azithromycin 500',
      image: 'assets/medicine3.jpeg',
      price: 20.0,
      quantity: 12,
      description: 'Antibiotic for cough',
    ),
    Pill(
      name: 'Emeset 4',
      image: 'assets/medicine4.jpeg',
      price: 10.0,
      quantity: 10,
      description: 'For nausea and vomiting',
    ),
    Pill(
      name: 'Cetrizine 10mg',
      image: 'assets/medicine5.jpeg',
      price: 12.0,
      quantity: 20,
      description: 'Antibiotic for cold',
    ),
    Pill(
      name: 'Brufen 400mg',
      image: 'assets/medicine6.jpeg',
      price: 30.0,
      quantity: 15,
      description: 'Pain killer',
    ),
    Pill(
      name: 'Pan D',
      image: 'assets/medicine7.jpeg',
      price: 30.0,
      quantity: 20,
      description: 'For stomach ulcers',
    ),
    Pill(
      name: 'Ivermectin 6',
      image: 'assets/medicine8.jpeg',
      price: 15.0,
      quantity: 20,
      description: 'For COVID-19 and lung infections',
    ),
    // Add more pills here
  ];

  List<Pill> cart = [];
  List<Pill> filteredPills = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    filteredPills = List.from(pills);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pills'),
        backgroundColor: Colors.blue, // Use your desired color here
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search pills by name or description',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (text) {
                filterPills(text);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPills.length,
              itemBuilder: (context, index) {
                return PillCard(
                  pill: filteredPills[index],
                  onQuantityChanged: (quantity) {
                    setState(() {
                      filteredPills[index].quantity = quantity;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CartScreen(cart: cart)),
          );
        },
        child: Icon(Icons.shopping_cart),
        backgroundColor: Colors.blue, // Use your desired color here
      ),
    );
  }

  void filterPills(String query) {
    setState(() {
      filteredPills = pills
          .where((pill) =>
      pill.name.toLowerCase().contains(query.toLowerCase()) ||
          pill.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
}

class Pill {
  final String name;
  final String image;
  final double price;
  int quantity;
  final String description;
  bool isExpanded;

  Pill({
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    required this.description,
    this.isExpanded = false,
  });
}

class PillCard extends StatefulWidget {
  final Pill pill;
  final Function(int) onQuantityChanged;

  PillCard({required this.pill, required this.onQuantityChanged});

  @override
  _PillCardState createState() => _PillCardState();
}

class _PillCardState extends State<PillCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(20),
      child: Column(
        children: [
          ListTile(
            leading: Image.asset(widget.pill.image, width: 60, height: 60),
            title: Text(widget.pill.name),
            trailing: Text('\$${widget.pill.price.toStringAsFixed(2)}'),
          ),
          if (widget.pill.isExpanded)
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Description: ${widget.pill.description}'),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Quantity: ${widget.pill.quantity} pills'),
                      ElevatedButton(
                        onPressed: () {
                          widget.onQuantityChanged(widget.pill.quantity);
                        },
                        child: Text('Add to Cart'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ListTile(
            title: Text('Tap to expand'),
            onTap: () {
              setState(() {
                widget.pill.isExpanded = !widget.pill.isExpanded;
              });
            },
          ),
        ],
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  final List<Pill> cart;

  CartScreen({required this.cart});

  double getTotalCost() {
    double total = 0;
    for (var item in cart) {
      total += item.price * item.quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        backgroundColor: Colors.blue, // Use your desired color here
      ),
      body: ListView.builder(
        itemCount: cart.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.asset(cart[index].image, width: 40, height: 40),
            title: Text(cart[index].name),
            subtitle: Text('Quantity: ${cart[index].quantity} pills'),
            trailing: Text('\$${(cart[index].price * cart[index].quantity).toStringAsFixed(2)}'),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Text('Total Cost: \$${getTotalCost().toStringAsFixed(2)}'),
        ),
      ),
    );
  }
}

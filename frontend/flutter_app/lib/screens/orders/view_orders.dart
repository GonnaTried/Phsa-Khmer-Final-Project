import 'package:flutter/material.dart';

class ViewOrders extends StatefulWidget{
  const ViewOrders({super.key});

  @override
  State<ViewOrders> createState() => _ViewOrdersState();
}

class _ViewOrdersState extends State<ViewOrders> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
      ),
      body: const Center(
        child: Text("Order history will be displayed here."),
      ),
    );
  }

}
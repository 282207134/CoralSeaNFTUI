import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../../domain/models.dart';
import '../../shared/widgets.dart';
import '../../state/marketplace_store.dart';
import '../marketplace/detail_screen.dart';
import '../wallet/onboarding_screen.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});
  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      description = TextEditingController(),
      price = TextEditingController(),
      royalties = TextEditingController(),
      propertyName = TextEditingController(),
      propertyValue = TextEditingController(),
      alt = TextEditingController();
  String? image;
  Uint8List? bytes;
  String saleType = 'Fixed Price',
      category = 'Art',
      collection = 'Untitled Collection';
  final collections = ['Untitled Collection', 'The Architecture Series'];
  String? error;
  bool busy = false;
  Nft? created;
  @override
  void dispose() {
    for (final controller in [
      name,
      description,
      price,
      royalties,
      propertyName,
      propertyValue,
      alt,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (created != null) {
      return PageFrame(
        title: 'Create New Item',
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 88,
                    color: coralYellow,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your art is ready.',
                    style: context.text.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${created!.name} is now in your collection. This demo item is stored on your device.',
                    textAlign: TextAlign.center,
                    style: context.text.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ArtImage(created!),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(nft: created!),
                      ),
                    ),
                    child: const Text('View Item'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return PageFrame(
      title: 'Create New Item',
      child: Form(
        key: form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Text('Upload your NFT', style: context.text.titleSmall),
            const SizedBox(height: 10),
            InkWell(
              key: const Key('choose-artwork'),
              onTap: _chooseArt,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 200,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: context.colors.outline.withValues(alpha: .5),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: image == null && bytes == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.image_outlined,
                            color: coralYellow,
                            size: 46,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Choose your artwork',
                            style: context.text.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Select a demo artwork or upload a photo\nJPG, PNG, WEBP · Up to 2 MB after resizing',
                            textAlign: TextAlign.center,
                            style: context.text.bodySmall!.copyWith(
                              fontSize: 10,
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          bytes != null
                              ? Image.memory(bytes!, fit: BoxFit.cover)
                              : Image.asset(
                                  'assets/images/$image.png',
                                  fit: BoxFit.cover,
                                ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Chip(
                              label: const Text('Change artwork'),
                              backgroundColor: context.colors.surface,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            _field(
              'Name',
              name,
              'Enter your item name',
              key: const Key('item-name'),
              required: true,
              maxLength: 60,
            ),
            _field(
              'Description',
              description,
              'Provide a detailed description of your item',
              lines: 4,
              maxLength: 1000,
            ),
            const SizedBox(height: 20),
            Text('Put on market place', style: context.text.titleSmall),
            const SizedBox(height: 5),
            Text(
              'Choose how collectors can discover your work',
              style: context.text.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: ['Fixed Price', 'Open For Bid']
                  .map(
                    (v) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: v == 'Fixed Price' ? 8 : 0,
                          left: v == 'Fixed Price' ? 0 : 8,
                        ),
                        child: OutlinedButton.icon(
                          onPressed: () => setState(() => saleType = v),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: saleType == v
                                ? coralYellow
                                : Colors.transparent,
                            foregroundColor: saleType == v
                                ? ink
                                : context.colors.onSurface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            side: BorderSide(
                              color: saleType == v
                                  ? coralYellow
                                  : context.colors.outline,
                            ),
                          ),
                          icon: Icon(
                            v == 'Fixed Price'
                                ? Icons.sell_outlined
                                : Icons.all_inclusive,
                            size: 17,
                          ),
                          label: Text(v, style: const TextStyle(fontSize: 12)),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            _field(
              'Price',
              price,
              '0.00',
              key: const Key('item-price'),
              number: true,
              suffix: 'wETH',
              validator: _validatePrice,
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder(
              valueListenable: price,
              builder: (_, value, _) => Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: context.colors.outlineVariant),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Column(
                  children: [
                    _summary('Service Fee', '1%'),
                    const Divider(height: 22),
                    _summary(
                      'You will receive',
                      '${eth((double.tryParse(price.text) ?? 0) * .99)} ETH',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text('Collection', style: context.text.titleSmall),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: collection,
              isExpanded: true,
              items: collections
                  .map(
                    (v) => DropdownMenuItem(
                      value: v,
                      child: Text(v, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => collection = v!),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _newCollection,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New collection'),
              ),
            ),
            const SizedBox(height: 8),
            Text('Category', style: context.text.titleSmall),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: category,
              items: categories
                  .skip(1)
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) => category = v!,
            ),
            _field(
              'Royalties From Secondary Sales',
              royalties,
              'Percentage from 0 to 50',
              number: true,
              suffix: '%',
              validator: _validateRoyalties,
            ),
            const SizedBox(height: 20),
            Text('Properties (Optional)', style: context.text.titleSmall),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: propertyName,
                    decoration: const InputDecoration(hintText: 'e.g. Color'),
                    validator: (v) =>
                        propertyValue.text.isNotEmpty && v!.trim().isEmpty
                        ? 'Enter a property name.'
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextFormField(
                    controller: propertyValue,
                    decoration: const InputDecoration(hintText: 'e.g. Blue'),
                    validator: (v) =>
                        propertyName.text.isNotEmpty && v!.trim().isEmpty
                        ? 'Enter a value.'
                        : null,
                  ),
                ),
              ],
            ),
            _field(
              'Alternative text for NFT (Optional)',
              alt,
              'Describe the image for accessibility',
              lines: 3,
              maxLength: 250,
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Text(
                  error!,
                  style: TextStyle(color: context.colors.error),
                ),
              ),
            const SizedBox(height: 30),
            FilledButton(
              key: const Key('submit-item'),
              onPressed: busy ? null : _submit,
              child: Text(busy ? 'Creating…' : 'Create Item'),
            ),
          ],
        ),
      ),
    );
  }

  String? _validatePrice(String? value) {
    final n = double.tryParse(value ?? '');
    return n == null || !n.isFinite || n <= 0 || n > 1000000
        ? 'Enter a price greater than 0 and below 1,000,000.'
        : null;
  }

  Widget _field(
    String label,
    TextEditingController controller,
    String hint, {
    Key? key,
    bool required = false,
    int lines = 1,
    bool number = false,
    String? suffix,
    int? maxLength,
    String? Function(String?)? validator,
  }) => Padding(
    padding: const EdgeInsets.only(top: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.text.titleSmall),
        const SizedBox(height: 8),
        TextFormField(
          key: key,
          controller: controller,
          maxLines: lines,
          maxLength: maxLength,
          keyboardType: number
              ? const TextInputType.numberWithOptions(decimal: true)
              : lines > 1
              ? TextInputType.multiline
              : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
            counterText: '',
          ),
          validator:
              validator ??
              (v) => required && (v?.trim().isEmpty ?? true)
                  ? 'Please enter a name.'
                  : null,
        ),
      ],
    ),
  );
  Widget _summary(String label, String value) => Row(
    children: [
      Expanded(child: Text(label, style: context.text.bodySmall)),
      Text(value, style: const TextStyle(color: coralYellow, fontSize: 12)),
    ],
  );
  Future<void> _chooseArt() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Choose your artwork', style: context.text.titleMedium),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: seedNfts
                    .map(
                      (n) => InkWell(
                        key: Key('sample-${n.id}'),
                        onTap: () => Navigator.pop(context, n.image),
                        child: SizedBox(
                          width: 88,
                          height: 88,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: ArtImage(n),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context, 'upload'),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Upload from Photos'),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || result == null) return;
    if (result != 'upload') {
      setState(() {
        image = result;
        bytes = null;
        error = null;
      });
      return;
    }
    try {
      final photo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (photo == null) return;
      final data = await photo.readAsBytes();
      if (data.length > 2 * 1024 * 1024) {
        throw StateError('Choose an image smaller than 2 MB.');
      }
      if (mounted) {
        setState(() {
          bytes = data;
          image = null;
          error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'Could not load this photo. Please choose a JPG, PNG or WEBP image under 2 MB.',
        );
      }
    }
  }

  Future<void> _newCollection() async {
    var collectionName = '';
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Collection'),
        content: TextField(
          onChanged: (value) => collectionName = value,
          autofocus: true,
          maxLength: 40,
          decoration: const InputDecoration(hintText: 'Collection name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (collectionName.trim().isNotEmpty) {
                Navigator.pop(context, collectionName.trim());
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (value != null && mounted) {
      setState(() {
        if (!collections.contains(value)) collections.add(value);
        collection = value;
      });
    }
  }

  Future<void> _submit() async {
    final validation = name.text.trim().isEmpty
        ? 'Please enter a name.'
        : _validatePrice(price.text) ??
              _validateRoyalties(royalties.text) ??
              (propertyName.text.trim().isEmpty !=
                      propertyValue.text.trim().isEmpty
                  ? 'Enter both a property name and value.'
                  : null);
    if (validation != null) {
      form.currentState!.validate();
      setState(() => error = validation);
      return;
    }
    if (image == null && bytes == null) {
      setState(() => error = 'Choose an artwork before creating your item.');
      return;
    }
    if (!await ensureWallet(context) || !mounted) return;
    setState(() {
      busy = true;
      error = null;
    });
    final item = Nft(
      id: 'created-${DateTime.now().microsecondsSinceEpoch}',
      name: name.text.trim(),
      image: image ?? 'door',
      imageBase64: bytes == null ? null : base64Encode(bytes!),
      description: description.text.trim(),
      price: double.parse(price.text),
      royalties: double.tryParse(royalties.text) ?? 0,
      category: category,
      collection: collection,
      saleType: saleType,
      isCreated: true,
      likes: 0,
      properties: propertyName.text.trim().isEmpty
          ? {}
          : {propertyName.text.trim(): propertyValue.text.trim()},
      altText: alt.text.trim(),
    );
    try {
      await AppScope.of(context).create(item);
      if (mounted) setState(() => created = item);
    } on StateError catch (e) {
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String? _validateRoyalties(String? value) {
    final n = double.tryParse(
      value?.trim().isEmpty == true ? '0' : value ?? '0',
    );
    return n == null || !n.isFinite || n < 0 || n > 50
        ? 'Royalties must be between 0 and 50.'
        : null;
  }
}

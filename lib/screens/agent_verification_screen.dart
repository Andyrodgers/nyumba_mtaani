import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nyumba_mtaani/providers/supabase_provider.dart';
import 'package:nyumba_mtaani/repositories/verification_repository_impl.dart';

class AgentVerificationScreen extends ConsumerStatefulWidget {
  const AgentVerificationScreen({super.key});

  @override
  ConsumerState<AgentVerificationScreen> createState() => _AgentVerificationScreenState();
}

class _AgentVerificationScreenState extends ConsumerState<AgentVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _licenseController = TextEditingController();
  File? _idDocument;
  File? _licenseDocument;
  bool _isLoading = false;

  final _picker = ImagePicker();

  Future<void> _pickImage(bool isId) async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      setState(() {
        if (isId) {
          _idDocument = File(xFile.path);
        } else {
          _licenseDocument = File(xFile.path);
        }
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _idDocument == null || _licenseDocument == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and upload documents')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final client = ref.read(supabaseClientProvider);
    final repo = VerificationRepositoryImpl(client);
    
    final result = await repo.submitAgentVerification(
      licenseNumber: _licenseController.text,
      idDocument: _idDocument!,
      licenseDocument: _licenseDocument!,
    );

    setState(() => _isLoading = false);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification submitted successfully!')));
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agent Verification')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Verify your identity to post unlimited properties and get a verified badge.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _licenseController,
                decoration: const InputDecoration(
                  labelText: 'Real Estate License Number',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              _DocumentPicker(
                label: 'National ID / Passport',
                file: _idDocument,
                onTap: () => _pickImage(true),
              ),
              const SizedBox(height: 16),
              _DocumentPicker(
                label: 'License Document',
                file: _licenseDocument,
                onTap: () => _pickImage(false),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: _isLoading 
                    ? const CircularProgressIndicator() 
                    : const Text('Submit for Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentPicker extends StatelessWidget {
  final String label;
  final File? file;
  final VoidCallback onTap;

  const _DocumentPicker({required this.label, this.file, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: file != null
            ? Image.file(file!, fit: BoxFit.cover)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.upload_file, size: 40, color: Colors.grey),
                  Text(label),
                ],
              ),
      ),
    );
  }
}
